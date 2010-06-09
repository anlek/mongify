require File.join(File.dirname(File.dirname(File.dirname(File.expand_path(__FILE__)))), 'spec_helper')
require File.join(File.dirname(File.dirname(File.dirname(File.dirname(File.expand_path(__FILE__))))), 'lib', 'mongify', 'database', 'sql_config')

describe Mongify::Database::SqlConfig do
  before(:each) do
    @adapter = 'mysql'
    @host = '127.0.0.1'
    @database = 'test_database'
    @sql_config = Mongify::Database::SqlConfig.new
  end
  
  context "valid?" do
    it "should be true" do
      Mongify::Database::SqlConfig.new(:adapter => 'mysql', :host => 'localhost', :database => 'blue').should be_valid
    end
    it "should be false" do
      Mongify::Database::SqlConfig.new.should_not be_valid
    end
  end
  
  
  context "testing connection" do
    before(:each) do
      @sql_config = Mongify::Database::SqlConfig.new(:adapter => @adapter, :host => @host, :database => @database)
    end
    it "should work" do
      @sql_config.should have_connection
    end
  end
  
  
  

  
  
  
end

