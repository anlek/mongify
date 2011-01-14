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
    @translation.process(@sql_connection, @no_sql_connection)
  end
  
  context "copy" do
    before(:each) do
      @sql_connection = mock(:select_rows => [{'first_name'=> 'Timmy', 'last_name' => 'Zuza'}])
      @translation.stub(:sql_connection).and_return(@sql_connection)
  
      @no_sql_connection = mock(:insert_into => true)
      @translation.stub(:no_sql_connection).and_return(@no_sql_connection)
      
      @table = mock(:translate => {}, :name => 'users')
    end
    
    it "should call translate on the tables" do
      @translation.stub(:tables).and_return([@table])
      @table.should_receive(:translate).once.and_return({})
      @translation.send(:copy)
    end
  end
end
