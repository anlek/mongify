require File.dirname(__FILE__) + '/../spec_helper'

describe Mongify::Translation do
  before(:all) do
    @file_path = File.expand_path(File.dirname(__FILE__) + '/../files/simple_translation.rb')
    @translation = Mongify::Translation.parse(@file_path)
  end
  it "should read in file" do
    lambda{ Mongify::Translation.parse(@file_path) }.should_not raise_error(Mongify::FileNotFound)
  end
  
  context "loaded content" do
    context "tables" do
      it "should have 3 tables" do
        @translation.should have(3).tables
      end
      
      it "should setup 'user_accounts'" do
        table = @translation.tables.find{|t| puts t.name; t.name == 'user_accounts'}
        table.should_not be_nil
        table.options.keys.should_not be_empty
      end
    end
  end
end
