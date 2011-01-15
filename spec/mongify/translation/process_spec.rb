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
  
  it "should call copy" do
    @translation.should_receive(:copy)
    @translation.stub(:update_reference_ids)
    @translation.process(@sql_connection, @no_sql_connection)
  end
  it "should call update_reference_ids" do
    @translation.should_receive(:update_reference_ids)
    @translation.stub(:copy)
    @translation.process(@sql_connection, @no_sql_connection)
  end
  
  
  context "processing actions" do
    before(:each) do
      @sql_connection = mock(:select_rows => [{'first_name'=> 'Timmy', 'last_name' => 'Zuza'}])
      @translation.stub(:sql_connection).and_return(@sql_connection)
  
      @no_sql_connection = mock()
      @translation.stub(:no_sql_connection).and_return(@no_sql_connection)
      
      @table = mock(:translate => {}, :name => 'users')
      @translation.stub(:tables).and_return([@table])
    end
    
    context "copy" do
      it "should call translate on the tables" do
        @no_sql_connection.should_receive(:insert_into).and_return(true)
        @table.should_receive(:translate).once.and_return({})
        @translation.send(:copy)
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
  end
end
