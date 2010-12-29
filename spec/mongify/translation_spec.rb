require 'spec_helper'

describe Mongify::Translation do
  before(:all) do
    @file_path = File.expand_path(File.dirname(__FILE__) + '/../files/simple_translation.rb')
    @translation = Mongify::Translation.parse(@file_path)
  end
  
  context "parsed content" do
    context "tables" do
      it "should have 3 tables" do
        @translation.should have(3).tables
      end
      
      it "should setup 'user_accounts'" do
        table = @translation.tables.find{|t| t.name == 'user_accounts'}
        table.should_not be_nil
        table.options.keys.should_not be_empty
      end
    end
  end
  
  context "add_table" do
    before(:each) do
      @table = Mongify::Database::Table.new("users")
      @translation = Mongify::Translation.new()
    end
    it "should work" do
      lambda { @translation.add_table(@table) }.should change{@translation.tables.count}.by(1)
    end
  end
end
