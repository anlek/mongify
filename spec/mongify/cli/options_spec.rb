require File.join(File.dirname(File.dirname(File.dirname(File.expand_path(__FILE__)))), 'spec_helper')
require File.join(File.dirname(File.dirname(File.dirname(File.dirname(File.expand_path(__FILE__))))), 'lib', 'mongify', 'cli', 'options')

include Mongify
include Mongify::CLI 

describe Options do
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
  
end
