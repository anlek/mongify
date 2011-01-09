require 'spec_helper'

describe Mongify::CLI::WorkerCommand do
  before(:each) do
    @view = mock('view').as_null_object
  end
  context "non-existing command" do
     before(:each) do
      @command = Mongify::CLI::WorkerCommand.new('unknown')
    end
    
    it "should report error" do
      @view.should_receive(:report_error)
      @command.execute(@view)
    end
    
    it "should output an error" do
      @view.should_receive(:output).with("Unknown action unknown")
      @command.execute(@view)
    end
  end

  context "translate command" do
    before(:each) do
      @config = Mongify::Configuration.new()
      @command = Mongify::CLI::WorkerCommand.new('translate')
    end
  end
end
