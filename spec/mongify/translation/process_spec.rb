require 'spec_helper'

describe Mongify::Translation::Process do
  before(:each) do
    DatabaseGenerator.clear_mongodb
    @sql_connection = DatabaseGenerator.sqlite_connection
    @no_sql_connection = DatabaseGenerator.mongo_connection
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
    it "should setup index on pre_mongify_id" do
      @translation.should_receive(:setup_db_index)
      @translation.process(@sql_connection, @no_sql_connection)
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
    
    it "should add pre_mongified_id index to database" do
      tables = [stub(:name => 'users')]
      @translation.stub(:copy_tables).and_return(tables)
      @no_sql_connection.should_receive(:create_pre_mongified_id_index).with('users')
      @translation.process(@sql_connection, @no_sql_connection)
    end
  end
  
  it "should ask_to_drop_database if mongodb_connection is forced" do
    @no_sql_connection.should_receive(:forced?).and_return(true)
    @no_sql_connection.should_receive(:ask_to_drop_database).and_return(false)
    @translation.process(@sql_connection, @no_sql_connection)
  end
  
  context "fetch_reference_ids" do
    it "should get correct information" do
      @no_sql_connection = mock()
      @translation.stub(:no_sql_connection).and_return(@no_sql_connection)
      @table = mock(:translate => {}, :name => 'users', :embedded? => false)
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
      
      @table = mock(:translate => {'first_name'=> 'Timmy', 'last_name' => 'Zuza', 'preference_id' => 1},
                    :name => 'users', 
                    :embedded? => false, 
                    :sql_name => 'users')
                    
      @translation.stub(:tables).and_return([@table])
    end
    
    context "copy_data" do
      it "should call translate on the tables" do
        @no_sql_connection.should_receive(:insert_into).with("users", {"last_name"=>"Zuza", "preference_id"=>1, "first_name"=>"Timmy"}).and_return(true)
        @translation.send(:copy_data)
      end
      it "should allow rename of table" do
        @table.stub(:name).and_return('people')
        @no_sql_connection.should_receive(:insert_into).with("people", {"last_name"=>"Zuza", "preference_id"=>1, "first_name"=>"Timmy"}).and_return(true)
        @translation.send(:copy_data)
      end
    end
    
    context "copy_embed_tables" do
      before(:each) do
        @target_table = mock(:name => 'posts', :embedded? => false, :sql_name => 'posts')
        @embed_table = mock(:translate => {}, :name => 'comments', :embedded? => true, :embed_on => 'post_id', :embed_in => 'posts', :embedded_as_object? => false, :sql_name => 'comments')
        @no_sql_connection.stub(:find_one).and_return({'_id' => 500})
        @translation.stub(:tables).and_return([@target_table, @embed_table])
        @translation.stub(:fetch_reference_ids).and_return({})
      end
      it "should loop through embedded tables" do
        @translation.should_receive(:embed_tables).at_least(1).and_return([@embed_table])
        @no_sql_connection.should_receive(:find_one).and_return({'_id' => 500})
        @no_sql_connection.should_receive(:update)
        @translation.send(:copy_embedded_tables)
      end
      it "should remove the pre_mongified_id before embedding" do
        @embed_table = mock(:translate => {'first_name' => 'bob', 'pre_mongified_id' => 1}, :name => 'comments', :sql_name => 'comments', :embedded? => true, :embed_on => 'post_id', :embed_in => 'posts', :embedded_as_object? => false)
        @translation.stub(:tables).and_return([@target_table, @embed_table])
        @no_sql_connection.should_receive(:update).with("posts", 500, {"$addToSet"=>{"comments"=>{'first_name' => 'bob'}}})
        @translation.send(:copy_embedded_tables)
      end
      it "should remove the parent_id from the embedding row" do
        @embed_table = mock(:translate => {'first_name' => 'bob', 'post_id' => 1}, :name => 'comments', :sql_name => 'comments', :embedded? => true, :embed_on => 'post_id', :embed_in => 'posts', :embedded_as_object? => false)
        @translation.stub(:tables).and_return([@target_table, @embed_table])
        @no_sql_connection.should_receive(:update).with("posts", 500, {"$addToSet"=>{"comments"=>{'first_name' => 'bob'}}})
        @translation.send(:copy_embedded_tables)
      end
      it "should call $addToSet on update of an embed_as_object table" do
        @embed_table = mock(:translate => {'first_name' => 'bob', 'post_id' => 1}, :name => 'comments', :sql_name => 'comments', :embedded? => true, :embed_on => 'post_id', :embed_in => 'posts', :embedded_as_object? => true)
        @translation.stub(:tables).and_return([@target_table, @embed_table])
        @no_sql_connection.should_receive(:update).with("posts", 500, {"$set"=>{"comments"=>{'first_name' => 'bob'}}})
        @translation.send(:copy_embedded_tables)
      end
      it "should allow rename of table" do
        @embed_table = mock(:translate => {'first_name' => 'bob', 'post_id' => 1}, :name => 'notes', :sql_name => 'comments', :embedded? => true, :embed_on => 'post_id', :embed_in => 'posts', :embedded_as_object? => true)
        @translation.stub(:tables).and_return([@target_table, @embed_table])
        @no_sql_connection.should_receive(:update).with("posts", 500, {"$set"=>{"notes"=>{'first_name' => 'bob'}}})
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
    
    context "copy_polymorphic_tables" do
      before(:each) do
        @ref_table = mock(:name => 'user_accounts', 
                          :embedded? => false,
                          :ignored? => false,
                          :sql_name => 'user_accounts')
        @translation.stub(:find).with('user_accounts').and_return([@ref_table])
        
        @sql_connection.stub(:select_rows).with('comments').and_return([{'commentable_id' => 1, 'commentable_type' => 'UserAccount', 'data' => 'good'}])
        @no_sql_connection.stub(:get_id_using_pre_mongified_id).with('user_accounts', 1).and_return(500)
      end
      context "embedded" do
        it "should work correctly" do
           @table = mock(:translate => {'data' => 123},
                          :name => 'comments', 
                          :embedded? => true,
                          :polymorphic_as => 'commentable',
                          :polymorphic? => true, 
                          :ignored? => false,
                          :embedded_as_object? => false,
                          :sql_name => 'comments',
                          :reference_columns => [])

            @translation.stub(:all_tables).and_return([@table])
          
          @no_sql_connection.should_receive(:update).with('user_accounts', 500, {'$addToSet' => {'comments' => {'data' => 123}}})
          @translation.send(:copy_polymorphic_tables)
        end
      end
      context "not embedded" do
        it "should work" do
          @table = mock(:translate => {'data' => 123, 'commentable_type' => 'UserAccount', 'commentable_id' => 1},
                          :name => 'comments', 
                          :embedded? => false,
                          :polymorphic_as => 'commentable',
                          :polymorphic? => true, 
                          :ignored? => false,
                          :embedded_as_object? => false,
                          :sql_name => 'comments',
                          :reference_columns => [])

          @translation.stub(:all_tables).and_return([@table])
          @no_sql_connection.should_receive(:get_id_using_pre_mongified_id).with('user_accounts', 1).and_return(500)
          @no_sql_connection.should_receive(:insert_into).with('comments', {'data' => 123, 'commentable_type' => 'UserAccount', 'commentable_id' => 500})
          @translation.send(:copy_polymorphic_tables)
        end
        it "should copy even if there is no polymorphic data" do
          @table = mock(:translate => {'data' => 123, 'commentable_type' => nil, 'commentable_id' => nil},
                          :name => 'comments', 
                          :embedded? => false,
                          :polymorphic_as => 'commentable',
                          :polymorphic? => true, 
                          :ignored? => false,
                          :embedded_as_object? => false,
                          :sql_name => 'comments',
                          :reference_columns => [])

          @translation.stub(:all_tables).and_return([@table])
          @sql_connection.should_receive(:select_rows).with('comments').and_return([{'commentable_id' => nil, 'commentable_type' => nil, 'data' => 'good'}])
          @no_sql_connection.should_receive(:insert_into).with('comments', {'data' => 123, 'commentable_type' => nil, 'commentable_id' => nil})
          @no_sql_connection.should_receive(:get_id_using_pre_mongified_id).never
          @translation.send(:copy_polymorphic_tables)
        end
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
