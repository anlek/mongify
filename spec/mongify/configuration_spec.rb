require File.join(File.dirname(File.dirname(File.expand_path(__FILE__))), 'spec_helper')
require File.join(File.dirname(File.dirname(File.dirname(File.expand_path(__FILE__)))), 'lib', 'mongify', 'configuration')

describe Mongify::Configuration do
  before(:each) do
    Mongify::Translation.stub(:parse)
    @translation_file = File.expand_path(File.dirname(__FILE__) + '/../files/empty_translation.rb')
    @configuration_file = File.expand_path(File.dirname(__FILE__) + '/../files/base_configuration.rb')
  end
  it "should parse file for transaltion" do
    Mongify::Translation.should_receive(:parse).and_return(true)
    Mongify::Configuration.parse_translation(@translation_file)
  end
  
  it "should parse confg file" do
    Mongify::Configuration.should_receive(:parse).and_return(true)
    Mongify::Configuration.parse_configuration(@configuration_file)
  end
  
  it "should validate file exists" do
    lambda { Mongify::Configuration.parse_configuration("../missing_file.rb") }.should raise_error(Mongify::FileNotFound)
  end
  
  context "load database config" do
    before(:each) do
      
    end
    it "should load sql_config" do
      Mongify::Database::SqlConfig.should_receive(:new)
      @configuration = Mongify::Configuration.parse_configuration(@configuration_file)
    end
    it "should load nosql_config" do
      Mongify::Database::NoSqlConfig.should_receive(:new)
      @configuration = Mongify::Configuration.parse_configuration(@configuration_file)
    end
  end
end