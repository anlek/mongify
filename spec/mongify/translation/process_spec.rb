require 'spec_helper'

describe Mongify::Translation::Process do
  before(:each) do
    GenerateDatabase.clear_mongodb
    @sql_connection = GenerateDatabase.sqlite_connection
    @no_sql_connection = GenerateDatabase.mongo_connection
    @translation = Mongify::Translation.new
  end
  
  it "validates a sqlconnection" do
    lambda { @translation.process('bad param', 'bad param2') }.should raise_error(Mongify::SqlConnectionRequired)
  end
  
  it "should require a NoSqlConnection" do
    lambda { @translation.process(@sql_connection, 'bad param2') }.should raise_error(Mongify::NoSqlConnectionRequired)
  end
  
  describe "process" do
    before(:each) do
      @translation.stub(:remove_pre_mongified_ids)
      @translation.stub(:update_reference_ids)
      @translation.stub(:copy_data)
      @translation.stub(:copy_embedded_tables)
    end
    it "should call copy_data" do
      @translation.should_receive(:copy_data)
      @translation.process(@sql_connection, @no_sql_connection)
    end
    it "should call update_reference_ids" do
      @translation.should_receive(:update_reference_ids)
      @translation.process(@sql_connection, @no_sql_connection)
    end
    it "should call copy_embedded_tables" do
      @translation.should_receive(:copy_embedded_tables)
      @translation.process(@sql_connection, @no_sql_connection)
    end
    it "shuld call remove_pre_mongified_ids" do
      @translation.should_receive(:remove_pre_mongified_ids)
      @translation.process(@sql_connection, @no_sql_connection)
    end
  end
  
  
  
  context "fetch_reference_ids" do
    it "should get correct information" do
      @no_sql_connection = mock()
      @translation.stub(:no_sql_connection).and_return(@no_sql_connection)
      @table = mock(:translate => {}, :name => 'users', :embed? => false)
      @column = mock(:name => 'user_id', :references => 'users')
      @table.stub(:reference_columns).and_return([@column])
      @no_sql_connection.should_receive(:get_id_using_pre_mongified_id).with('users', 1).once.and_return(500)
      @translation.send(:fetch_reference_ids, @table, {'user_id' => 1}).should == {'user_id' => 500}
    end
  end
  
  context "processing actions" do
    before(:each) do
      @sql_connection = mock(:select_rows => [{'first_name'=> 'Timmy', 'last_name' => 'Zuza', 'preference_id' => 1}])
      @translation.stub(:sql_connection).and_return(@sql_connection)
  
      @no_sql_connection = mock()
      @translation.stub(:no_sql_connection).and_return(@no_sql_connection)
      
      @table = mock(:translate => {}, :name => 'users', :embed? => false)
      @translation.stub(:tables).and_return([@table])
    end
    
    context "copy_data" do
      it "should call translate on the tables" do
        @no_sql_connection.should_receive(:insert_into).and_return(true)
        @table.should_receive(:translate).once.and_return({})
        @translation.send(:copy_data)
      end
    end
    
    context "copy_embed_tables" do
      before(:each) do
        @target_table = mock(:name => 'posts', :embed? => false)
        @embed_table = mock(:translate => {}, :name => 'comments', :embed? => true, :embed_on => 'post_id', :embed_in => 'posts')
        @translation.stub(:tables).and_return([@target_table, @embed_table])
        @translation.stub(:fetch_reference_ids).and_return({})
      end
      it "should loop through embedded tables" do
        @translation.should_receive(:embed_tables).and_return([@embed_table])
        @no_sql_connection.should_receive(:find_one).and_return({'_id' => 500})
        @no_sql_connection.should_receive(:update)
        @translation.send(:copy_embedded_tables)
      end
    end
    
    context "update_reference_ids" do
      it "should work correctly" do
        @no_sql_connection.should_receive(:select_rows).and_return([{'_id' => 100, 'user_id' => 1}, {'_id'=> 101, 'user_id' => 2}])
        @no_sql_connection.stub(:get_id_using_pre_mongified_id).twice.and_return(500)
        @table.should_receive(:reference_columns).twice.and_return([mock(:name => 'user_id', :references=>'users')])
        @no_sql_connection.should_receive(:update).twice
        @translation.send(:update_reference_ids)
      end
      it "should only update when new_id is present" do
        @no_sql_connection.should_receive(:select_rows).and_return([{'_id' => 100, 'user_id' => 1}, {'_id'=> 101, 'user_id' => 2}])
        @no_sql_connection.stub(:get_id_using_pre_mongified_id).twice.and_return(nil)
        @table.should_receive(:reference_columns).twice.and_return([mock(:name => 'user_id', :references=>'users')])
        @no_sql_connection.should_receive(:update).never
        @translation.send(:update_reference_ids)
      end
    end
    
    context "remove_pre_mongified_ids" do
      it "should remove_pre_mongified_ids on no_sql_connection" do
        @no_sql_connection.should_receive(:remove_pre_mongified_ids).with(anything)
        @translation.send(:remove_pre_mongified_ids)
      end
    end
  end
end
