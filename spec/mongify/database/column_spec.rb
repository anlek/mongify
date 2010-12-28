require File.join(File.dirname(File.dirname(File.dirname(File.expand_path(__FILE__)))), 'spec_helper')
require File.join(File.dirname(File.dirname(File.dirname(File.dirname(File.expand_path(__FILE__))))), 'lib', 'mongify', 'database', 'column')

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
end
