require 'spec_helper'

describe Mongify::Database::Reader do
  before(:each) do
    @db_path = GenerateDatabase.run
    @sql_connection = Mongify::Database::SqlConnection.new(:adapter => 'sqlite3', :database => @db_path)
    @reader = Mongify::Database::Reader.new(@sql_connection)
  end
  
  context "connection parameter" do
    it "should be required" do
      lambda {Mongify::Database::Reader.new()}.should raise_error(ArgumentError)
    end
    
    it "should only take sql_connections" do
      lambda {Mongify::Database::Reader.new("Something else")}.should raise_error(Mongify::SqlConnectionRequired)
    end
  end
  
  it "should return a translation" do
    translation = @reader.translation
    translation.should be_a(Mongify::Translation)
  end
  
  context "print" do
    it "should run" do
      lambda { @reader.print }.should_not raise_error
    end
    
    it "should output correct database format" do
      output = @reader.print
      output.should == (DATABASE_PRINT)
    end
  end
  
end
