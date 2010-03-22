require File.dirname(__FILE__) + '/../spec_helper'

describe Mongify::Runner do
  before(:each) do
    @output = mock('output')
    @output.stubs(:puts)
    @valid_args = ['check', 'spec/files/empty_translation.rb']
  end
  
  it "should run and finish fully" do
    @output.expects(:puts).with('[DONE]')
    runner = Mongify::Runner.new(@valid_args, nil, @output).run
  end
  
  context "Config" do
    it "should set in_stream" do
      input = stub('input')
      runner = Mongify::Runner.new(@valid_args, input, @output).run  
      Mongify::Config.in_stream.should == input
    end
    
    it "should set out_stream" do
      output = stub('output')
      output.stubs(:puts)
      runner = Mongify::Runner.new(@valid_args, nil, output).run
      Mongify::Config.out_stream.should == output
    end
    
    it "should set path" do
      runner = Mongify::Runner.new(@valid_args, nil, @output).run
      Mongify::Config.file_path.should == File.expand_path(@valid_args[1])
    end
  end
end