require File.dirname(__FILE__) + '/../../spec_helper'

describe Mongify::Database::Column do
  before(:each) do
    @column = Mongify::Database::Column.new('first_name')
  end
  
  it "should have name" do
    @column.name = 'last_name'
    @column.name.should == 'last_name'
  end
  
  it "should get setup options" do
    @column = Mongify::Database::Column.new('account_id', :references => 'accounts')
    @column.options.should == {'references' => 'accounts'}
  end
end
