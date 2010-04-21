require File.join(File.dirname(File.dirname(File.expand_path(__FILE__))), 'spec_helper')
require File.join(File.dirname(File.dirname(File.dirname(File.expand_path(__FILE__)))), 'lib', 'mongify', 'configuration')

describe Mongify::Configuration do
  before(:each) do
    Mongify::Translation.stubs(:parse)
    @translation_file = File.expand_path(File.dirname(__FILE__) + '/../files/empty_translation.rb')
    @configuration_file = File.expand_path(File.dirname(__FILE__) + '/../files/base_configuration.rb')
  end
  it "should parse file for transaltion" do
    Mongify::Translation.expects(:parse).returns(true)
    Mongify::Configuration.parse_translation(@translation_file)
  end
  
  it "should parse confg file" do
    Mongify::Configuration.expects(:parse).returns(true)
    Mongify::Configuration.parse_configuration(@configuration_file)
  end
  
  it "should validate file exists" do
    lambda { Mongify::Configuration.parse_configuration("../missing_file.rb") }.should raise_error(Mongify::FileNotFound)
  end
  
  context "loaded content" do
    before(:each) do
      @configuration = Mongify::Configuration.parse_configuration(@configuration_file)
    end
    it "should have correct sql_config" do
      @configuration.sql_config.connection_string.should == "mysql://localhost/my_database"
    end
    it "should have correct mongodb_config" do
      @configuration.mongodb_config.connection_string.should == "mongo://127.0.0.1/my_collection"
    end
  end
end