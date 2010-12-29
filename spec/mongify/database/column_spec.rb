require 'spec_helper'

describe Mongify::Database::Column do
  before(:each) do
    @column = Mongify::Database::Column.new('first_name')
  end
  
  it "should have name" do
    @column.name.should == 'first_name'
  end
  
  it "should get setup options" do
    @column = Mongify::Database::Column.new('account_id', :integer, :references => 'accounts')
    @column.options.should == {'references' => 'accounts'}
  end
  
  it "should force type to string if nil" do
    @column = Mongify::Database::Column.new('first_name', nil)
    @column.type.should == :string
  end
end
