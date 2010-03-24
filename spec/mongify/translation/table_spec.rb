require File.dirname(__FILE__) + '/../../spec_helper'

describe Mongify::Translation::Table do
  before(:each) do
    @table = Mongify::Translation::Table.new('users')
  end
  
  it "should have name" do
    @table.name = 'accounts'
    @table.name.should == 'accounts'
  end
  
  it "should get setup options" do
    @table = Mongify::Translation::Table.new('users', :embed_in => 'accounts', :as => 'users')
    @table.options.should == {'embed_in' => 'accounts', 'as' => 'users'}
  end
end
