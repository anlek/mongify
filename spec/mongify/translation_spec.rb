require File.dirname(__FILE__) + '/../spec_helper'

describe Mongify::Translation do
  before(:all) do
    @file_path = File.expand_path(File.dirname(__FILE__) + '/../files/simple_translation.rb')
    @translation = Mongify::Translation.parse(@file_path)
  end
  it "should read in file" do
    lambda{ Mongify::Translation.parse(@file_path) }.should_not raise_error
  end
  
  context "loaded content" do
    it "should have correct sql_config" do
      @translation.sql_config.connection_string.should == "mysql://localhost/my_database"
    end
    it "should have correct mongodb_config" do
      @translation.mongodb_config.connection_string.should == "mongo://127.0.0.1/my_collection"
    end
    
    context "tables" do
      it "should have 3 tables" do
        @translation.should have(3).tables
      end
    end
  end
end
