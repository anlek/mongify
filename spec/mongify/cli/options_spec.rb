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
  
  context "action" do
    it "should get action command" do
      @options = Mongify::CLI::Options.new(['check'])
      @options.send(:action).should == 'check'
    end
    
    it "should return blank if no action is sent" do
      @options = Mongify::CLI::Options.new(['-v'])
      @options.send(:action).should == ''
    end
  end
  
  context "translation" do
    it "should return path" do
      @options = Mongify::CLI::Options.new(['check', '-c', 'some/config', 'some/folder/translation'])
      @options.send(:translation_file).should == 'some/folder/translation'
    end
    
    it "should return nil if no path specified" do
      @options = Mongify::CLI::Options.new(['check', '-c', 'some/config'])
      @options.send(:translation_file).should be_nil
    end
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
