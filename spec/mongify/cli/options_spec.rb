require 'spec_helper'

describe Mongify::CLI::Options do
  before(:each) do
    @config_file = File.join(File.dirname(File.dirname(File.dirname(File.expand_path(__FILE__)))), 'files', 'base_configuration.rb')
  end
  it "should run help command when passed an -h" do
    @options = Mongify::CLI::Options.new(['-h'])
    @options.parse
    @options.instance_variable_get(:@command_class).should == Mongify::CLI::HelpCommand
  end
  
  it "should run version command when passed an -h" do
    @options = Mongify::CLI::Options.new(['-v'])
    @options.parse
    @options.instance_variable_get(:@command_class).should == Mongify::CLI::VersionCommand  
  end
  
  context "Configuration file" do
    it "should take option (-c) with a file" do
      @options = Mongify::CLI::Options.new(['-c', @config_file])
      @options.parse
      @options.instance_variable_get(:@config_file).should == @config_file
    end
  
    it "should be require" do
      @options = Mongify::CLI::Options.new(["database_translation.rb"])
      lambda {@options.parse}.should raise_error(Mongify::ConfigurationFileNotFound)
    end
    
    it "should call Configuration.parse" do
      Mongify::Configuration.should_receive(:parse)
      @options = Mongify::CLI::Options.new(['-c', @config_file])
      @options.parse
    end
  end
end
