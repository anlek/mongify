require File.join(File.dirname(File.dirname(File.dirname(File.expand_path(__FILE__)))), 'spec_helper')
require File.join(File.dirname(File.dirname(File.dirname(File.dirname(File.expand_path(__FILE__))))), 'lib', 'mongify', 'database', 'no_sql_config')

describe Mongify::Database::NoSqlConfig do
  before(:each) do
    @host = '127.0.0.1'
    @database = 'test_database'
    @mongodb_config = Mongify::Database::NoSqlConfig.new
  end
  
  context "valid?" do
    it "should be true" do
      Mongify::Database::NoSqlConfig.new(:host => 'localhost', :database => 'blue').should be_valid
    end
    it "should be false" do
      Mongify::Database::NoSqlConfig.new.should_not be_valid
    end
  end
  
  context "connection string" do
    before(:each) do
      @mongodb_config.host(@host)
      @mongodb_config.database(@database)
    end
    
    it "without username and password should render correctly" do
      @mongodb_config.connection_string.should == "mongo://#{@host}/#{@database}"
    end
    
    it "with username and password should render correctly" do
      @mongodb_config.username('bob')
      @mongodb_config.password('secret')
      @mongodb_config.connection_string.should == "mongo://bob:secret@#{@host}/#{@database}"
    end
  end
  
  it "should set database name when setting collection" do
    @mongodb_config.collection 'boss'
    @mongodb_config.to_hash[:database].should == 'boss'
  end
  
  
  
  
end

