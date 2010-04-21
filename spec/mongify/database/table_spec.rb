require File.join(File.dirname(File.dirname(File.dirname(File.expand_path(__FILE__)))), 'spec_helper')
require File.join(File.dirname(File.dirname(File.dirname(File.dirname(File.expand_path(__FILE__))))), 'lib', 'mongify', 'database', 'table')

describe Mongify::Database::Table do
  before(:each) do
    @table = Mongify::Database::Table.new('users')
  end
  
  it "should have name" do
    @table.name = 'accounts'
    @table.name.should == 'accounts'
  end
  
  it "should get setup options" do
    @table = Mongify::Database::Table.new('users', :embed_in => 'accounts', :as => 'users')
    @table.options.should == {'embed_in' => 'accounts', 'as' => 'users'}
  end
  
  context "column" do
    it "should be able to set" do
      @table.column 'name'
      @table.should have(1).columns
    end
    
    it "should be able to find" do
      @table.column 'dark'
      @table.find_column('dark').should_not be_nil
    end
    
    it "should return nil if not found" do
      @table.column 'dark'
      @table.find_column('blue').should be_nil
    end
  end
end
