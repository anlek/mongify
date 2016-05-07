require 'spec_helper'

describe Mongify::Database::BaseConnection do
  before(:each) do
    @base_connection = Mongify::Database::BaseConnection.new
  end
  it "should set any allowed variable name that's passed" do
    @base_connection = Mongify::Database::BaseConnection.new(:host => 'blue', :adapter => 'good')
    @base_connection.host.should == 'blue'
    @base_connection.adapter.should == 'good'
    # @base_connection.instance_variables.should =~ ['@host', '@adapter']
  end
  it "should not set unknown variables on init" do
    @base_connection = Mongify::Database::BaseConnection.new(:apple => 'blue')
    @base_connection.host.should be_nil
  end

  context "validation" do
    it "should be true" do
      @base_connection.host 'localhost'
      @base_connection.host.should == "localhost"
      @base_connection.should be_valid
    end

    it "should be false" do
      @base_connection.should_not be_valid
    end
  end

  it "should raise error when trying to call has_connection?" do
    lambda { @base_connection.has_connection? }.should raise_error(Mongify::NotImplementedMongifyError)
  end
  it "should raise error when trying to call setup_connection_adapter" do
    lambda { @base_connection.setup_connection_adapter}.should raise_error(Mongify::NotImplementedMongifyError)
  end

  it "should raise error on setting unknown variable setting" do
    lambda{@base_connection.connection = "localhost"}.should raise_error
  end

  it "should respond to available settings" do
    @base_connection.respond_to?(:host).should be_truthy
  end

  it "should force adapter to a string" do
    @base_connection.adapter :sqlite
    @base_connection.adapter.should == 'sqlite'
  end

  it "should leave port argument as an integer" do
    @base_connection.port 3333
    @base_connection.port.should == 3333
  end

  context "hash" do
    before(:each) do
      @adapter = 'baseDB'
      @host = '127.0.0.1'
      @database = 'test_database'
    end
    it "should give settings in a hash" do
      @sql_connection = Mongify::Database::BaseConnection.new(:adapter => @adapter, :host => @host, :database => @database)
      @sql_connection.to_hash.should == {:adapter => @adapter, :host => @host, :database => @database}
    end
    it "should setup from constructor hash" do
      @sql_connection = Mongify::Database::BaseConnection.new(:adapter => @adapter, :host => @host, :database => @database)
      @sql_connection.to_hash.should == {:adapter => @adapter, :host => @host, :database => @database}
    end
  end
end
