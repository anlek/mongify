require File.join(File.dirname(File.dirname(File.dirname(File.expand_path(__FILE__)))), 'spec_helper')
require File.join(File.dirname(File.dirname(File.dirname(File.dirname(File.expand_path(__FILE__))))), 'lib', 'mongify', 'database', 'base_config')

describe Mongify::Database::BaseConfig do
  before(:each) do
    @base_config = Mongify::Database::BaseConfig.new
  end
  it "should set any variable name that's passed" do
    @base_config = Mongify::Database::BaseConfig.new(:apple => 'blue', :car => 'good')
    @base_config.instance_variables.should =~ ['@apple', '@car']
  end
  
  context "validation" do
    it "should be true" do
      @base_config.host 'localhost'
      @base_config.should be_valid
    end
    
    it "should be false" do
      @base_config.should_not be_valid
    end
  end
  
  it "should raise error on setting unknown variable setting" do
    lambda{@base_config.connection = "localhost"}.should raise_error
  end
  
  it "should respond to available settings" do
    @base_config.respond_to?(:host).should be_true
  end
  
  context "hash" do
    before(:each) do
      @adaptor = 'baseDB'
      @host = '127.0.0.1'
      @database = 'test_database'
    end
    it "should give settings in a hash" do
      @sql_config = Mongify::Database::BaseConfig.new(:adaptor => @adaptor, :host => @host, :database => @database)
      @sql_config.to_hash.should == {:adaptor => @adaptor, :host => @host, :database => @database}
    end
    it "should setup from constructor hash" do
      @sql_config = Mongify::Database::BaseConfig.new(:adaptor => @adaptor, :host => @host, :database => @database)
      @sql_config.to_hash.should == {:adaptor => @adaptor, :host => @host, :database => @database}
    end
  end
end
