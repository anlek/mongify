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

  # using check here just so that it doesn't have translate but still tests the args properly
  context "translation" do
    it "should return path" do
      @options = Mongify::CLI::Options.new(['check', @config_file, 'some/folder/translation'])
      @options.send(:translation_file).should == 'some/folder/translation'
    end

    it "should return nil if no path specified" do
      @options = Mongify::CLI::Options.new(['check', @config_file])
      @options.send(:translation_file).should be_nil
    end
  end


  context "config_file" do
    it "should get config after action" do
      @options = Mongify::CLI::Options.new(['check', @config_file])
      @options.parse
      @options.instance_variable_get(:@config_file).should_not be_nil
    end

    it "should be require" do
      @options = Mongify::CLI::Options.new(['check'])
      lambda {@options.parse}.should raise_error(Mongify::ConfigurationFileNotFound)
    end

    it "should call Configuration.parse" do
      Mongify::Configuration.should_receive(:parse)
      @options = Mongify::CLI::Options.new(['check', @config_file])
      @options.parse
    end
  end
end
