require File.join(File.dirname(File.dirname(File.dirname(File.expand_path(__FILE__)))), 'spec_helper')
require File.join(File.dirname(File.dirname(File.dirname(File.dirname(File.expand_path(__FILE__))))), 'lib', 'mongify', 'cli', 'options')

include Mongify
include Mongify::CLI 

describe Options do
  before(:each) do
    @config_file = File.join(File.dirname(File.dirname(File.dirname(File.expand_path(__FILE__)))), 'files', 'base_configuration.rb')
  end
  it "should run help command when passed an -h" do
    @options = Options.new(['-h'])
    @options.parse
    @options.instance_variable_get(:@command_class).should == Mongify::CLI::HelpCommand
  end
  
  it "should run version command when passed an -h" do
    @options = Options.new(['-v'])
    @options.parse
    @options.instance_variable_get(:@command_class).should == Mongify::CLI::VersionCommand  
  end
  
  context "Configuration file" do
    it "should take option (-c) with a file" do
      @options = Options.new(['-c', @config_file])
      @options.parse
      @options.instance_variable_get(:@config_file).should == @config_file
    end
  
    it "should be require" do
      @options = Options.new(["database_translation.rb"])
      lambda {@options.parse}.should raise_error(ConfigurationFileNotFound)
    end
    
    it "should call Configuration.parse" do
      Mongify::Configuration.should_receive(:parse)
      @options = Options.new(['-c', @config_file])
      @options.parse
    end
  end
end
