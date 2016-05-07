require 'spec_helper'

describe Mongify::Translation::Sync do
  before(:each) do
    DatabaseGenerator.clear_mongodb
    @sql_connection = DatabaseGenerator.sqlite_connection
    @no_sql_connection = DatabaseGenerator.mongo_connection
    @translation = Mongify::Translation.new
    Mongify::Configuration.out_stream = nil
  end

  it "validates a sqlconnection" do
    lambda { @translation.sync('bad param', 'bad param2') }.should raise_error(Mongify::SqlConnectionRequired)
  end

  it "should require a NoSqlConnection" do
    lambda { @translation.sync(@sql_connection, 'bad param2') }.should raise_error(Mongify::NoSqlConnectionRequired)
  end

  describe "sync" do
    before(:each) do
      @translation.stub(:setup_sync_table)
      @translation.stub(:setup_db_index)
      @translation.stub(:sync_data)
      @translation.stub(:set_last_updated_at)
      @translation.stub(:sync_update_reference_ids)
      @translation.stub(:copy_embedded_tables)
    end
    it "should create sync helper table if it doesn't exist" do
      @translation.should_receive(:setup_sync_table)
      @translation.sync(@sql_connection, @no_sql_connection)
    end
    it "should setup index on pre_mongify_id" do
      @translation.should_receive(:setup_db_index)
      @translation.sync(@sql_connection, @no_sql_connection)
    end
    it "should call copy_data" do
      @translation.should_receive(:sync_data)
      @translation.sync(@sql_connection, @no_sql_connection)
    end
    it "should call set_last_updated_at to mark synced data in the source" do
      @translation.should_receive(:set_last_updated_at)
      @translation.sync(@sql_connection, @no_sql_connection)
    end
    it "should call sync_update_reference_ids" do
      @translation.should_receive(:sync_update_reference_ids)
      @translation.sync(@sql_connection, @no_sql_connection)
    end
    it "should call copy_embedded_tables" do
      @translation.should_receive(:copy_embedded_tables)
      @translation.sync(@sql_connection, @no_sql_connection)
    end
  end

  context "syncing actions" do
    before(:each) do
      @sql_connection = double(:select_rows => [{'first_name'=> 'Timmy', 'last_name' => 'Zuza', 'preference_id' => 1}])
      @translation.stub(:sql_connection).and_return(@sql_connection)

      @no_sql_connection = double()
      @translation.stub(:no_sql_connection).and_return(@no_sql_connection)

      @table = double(:translate => {'first_name'=> 'Timmy', 'last_name' => 'Zuza', 'preference_id' => 1},
                    :name => 'users',
                    :embedded? => false,
                    :sql_name => 'users')

      @translation.stub(:tables).and_return([@table])
    end

    context "SyncHelperMigrator" do
      it "should create a table with index in the up dir" do
        migrator = Mongify::Translation::Sync::SyncHelperMigrator.new
        helper = Mongify::Translation::Sync::SYNC_HELPER_TABLE
        t = double({:string => 1, :datetime => 1})
        t.should_receive(:string).with(:table_name)
        t.should_receive(:datetime).with(:last_updated_at)
        migrator.stub(:create_table).and_yield(t)
        migrator.should_receive(:create_table).with(helper, :id => false)
        migrator.stub(:add_index)
        migrator.should_receive(:add_index).with(helper, :table_name)
        migrator.up
      end
    end

    context "setup_sync_table" do
      before(:each) do
        @helper = Mongify::Translation::Sync::SYNC_HELPER_TABLE
        @query = "SELECT count(*) FROM #{@helper}"
        @sql_connection.stub(:execute).with(@query).and_return(5)
        @sql_connection.should_receive(:execute).with(@query)
        @translation.stub(:copy_tables).and_return([double(:sql_name => 'table1')])
      end

      it "should create sync helper table if it doesn't exist" do
        @sql_connection.stub(:execute).with(@query).and_raise
        migrator = double(:up)
        Mongify::Translation::Sync::SyncHelperMigrator.stub(:new).and_return(migrator)
        migrator.should_receive(:up)
        @translation.stub(:copy_tables).and_return([])
        @translation.send(:setup_sync_table)
      end

      it "should find rows for existing table representatives" do
        @sql_connection.stub(:count).and_return(1)
        @sql_connection.should_receive(:count).with(@helper, "table_name = 'table1'")
        @translation.send(:setup_sync_table)
      end

      it "should insert new records for non existing table representatives" do
        @sql_connection.stub(:count).and_return(0)
        @sql_connection.should_receive(:count).with(@helper, "table_name = 'table1'")
        insert_query = "INSERT INTO #{@helper} (table_name, last_updated_at) VALUES ('table1', '1970-01-01')"
        @sql_connection.stub(:execute).with(insert_query)
        @sql_connection.should_receive(:execute).with(insert_query)
        @translation.send(:setup_sync_table)
      end
    end

    context "set_last_updated_at" do
      it "should update last_updated_at timestamp for each table that generated sync data" do
        @translation.stub(:copy_tables).and_return([double(:sql_name => 'table1')])
        @translation.max_updated_at = {'table1' => {'max_updated_at_id' => 1, 'key_column' => 'id'}}
        helper = Mongify::Translation::Sync::SYNC_HELPER_TABLE
        query = "UPDATE #{helper} SET last_updated_at = (SELECT updated_at FROM table1 WHERE id = '1') WHERE table_name = 'table1'"
        @sql_connection.stub(:execute).with(query)
        @sql_connection.should_receive(:execute).with(query)
        @translation.send(:set_last_updated_at)
      end
      it "should not update last_updated_at timestamp for each table that did not generate any sync data" do
        @translation.stub(:copy_tables).and_return([double(:sql_name => 'table1')])
        @translation.max_updated_at = {}
        @translation.send(:set_last_updated_at)
        @translation.max_updated_at = {'table1' => {'key_column' => 'id'}}
        @translation.send(:set_last_updated_at)
      end
    end

    context "sync_data" do
      it "should upsert rows that match the new/updated query, mark them as drafts and compute the max updated at" do
        helper = Mongify::Translation::Sync::SYNC_HELPER_TABLE
        t = double(:sql_name => 'table1', :name => 'table1')
        @translation.stub(:copy_tables).and_return([t])
        t1, t2 = Time.new(1980).to_s, Time.new(2000).to_s
        rows = [{"id" => 1, "updated_at" => t1}, {"id" => 2, "updated_at" => t2}]
        t.stub(:translate).twice.and_return({'pre_mongified_id' => 1, 'updated_at' => t1}, {'pre_mongified_id' => 2, 'updated_at' => t2})

        query = "SELECT t.* FROM table1 t, #{helper} u WHERE t.updated_at > u.last_updated_at AND u.table_name = 'table1'"
        @sql_connection.stub(:select_by_query).and_return(rows)
        @sql_connection.should_receive(:select_by_query).with(query)

        draft = Mongify::Translation::Sync::DRAFT_KEY

        @no_sql_connection.stub(:upsert).with('table1', {'pre_mongified_id' => 1, 'updated_at' => t1, draft => true}).and_return(true)
        @no_sql_connection.stub(:upsert).with('table1', {'pre_mongified_id' => 2, 'updated_at' => t2, draft => true}).and_return(true)
        @no_sql_connection.should_receive(:upsert).twice

        t.stub(:key_column).and_return(double({name: 'id'}))

        @translation.send(:sync_data)

        @translation.max_updated_at.should == {'table1' => {'max_updated_at_id' => 2, 'key_column' => 'id'}}

      end
    end

    context "sync_update_reference_ids" do
      it "should delete the draft key" do
        t = double(:name => 'table1')
        @translation.stub(:copy_tables).and_return([t])
        query = {Mongify::Translation::Sync::DRAFT_KEY => true}
        row = double
        row.stub(:[]).with("_id").and_return(1)
        @no_sql_connection.stub(:select_by_query).and_return([row])
        @no_sql_connection.should_receive(:select_by_query).with('table1', query)
        @translation.stub(:fetch_reference_ids).and_return({})
        @translation.should_receive(:fetch_reference_ids).with(t, row)
        @no_sql_connection.should_receive(:update).with('table1', 1, {"$unset" => query})
        @translation.send(:sync_update_reference_ids)
      end
    end

  end
end
