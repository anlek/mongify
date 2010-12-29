require 'spec_helper'

describe Mongify::Database::Reader do
  before(:each) do
    #TODO: make sure sqlite database exists
    @db_path = GenerateDatabase.run
    @sql_connection = Mongify::Database::SqlConnection.new(:adapter => 'sqlite3', :database => @db_path)
  end
  
  context "connection parameter" do
    it "should be required" do
      lambda {Mongify::Database::Reader.new()}.should raise_error(ArgumentError)
    end
    
    it "should only take sql_connections" do
      lambda {Mongify::Database::Reader.new("Something else")}.should raise_error(Mongify::SqlConnectionRequired)
    end
  end
  
  context "read" do
    before(:each) do
      @reader = Mongify::Database::Reader.new(@sql_connection)
    end
    
    it "should run" do
      lambda { @reader.read }.should_not raise_error
    end
    
    it "should return a translation" do
      translation = @reader.read
      translation.should be_a(Mongify::Translation)
    end
  end
  
end
