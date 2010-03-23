require File.dirname(__FILE__) + '/../spec_helper'

describe Mongify::CLI do
  before(:each) do
    @output = mock('output')
    @output.stubs(:puts)
    @valid_args = ['check', 'spec/files/empty_translation.rb']
  end
  
  it "should run and finish fully" do
    @output.expects(:puts).with('[DONE]')
    lambda{ Mongify::CLI.new(@valid_args, nil, @output).execute! }.should_not raise_error
  end
  
  context "Validation" do
    it "should not take 1 argument" do
      @valid_args = ['check']
      lambda {Mongify::CLI.new(@valid_args, nil, @output).execute!}.should raise_error(SystemExit)
    end
    
    it "should not take 3 arguemnts" do
      @valid_args << 'unexceptable'
      lambda {Mongify::CLI.new(@valid_args, nil, @output).execute!}.should raise_error(SystemExit)
    end
    
    it "should check if file exists" do
      @valid_args[1] = 'spec/files/missing_translation.rb'
      lambda {Mongify::CLI.new(@valid_args, nil, @output).execute!}.should raise_error(SystemExit)
    end
    
    it "should check command exists" do
      @valid_args[0] = 'missing'
      lambda{Mongify::CLI.new(@valid_args, nil, @output).execute!}.should raise_error(SystemExit)
    end
  end
  
  context "Config" do
    it "should set in_stream" do
      input = stub('input')
      runner = Mongify::CLI.new(@valid_args, input, @output).execute!  
      Mongify::Configuration.in_stream.should == input
    end
    
    it "should set out_stream" do
      output = stub('output')
      output.stubs(:puts)
      runner = Mongify::CLI.new(@valid_args, nil, output).execute!
      Mongify::Configuration.out_stream.should == output
    end
    
    it "should set path" do
      runner = Mongify::CLI.new(@valid_args, nil, @output)
      runner.execute!
      runner.file_path.should == File.expand_path(@valid_args[1])
    end
    
    it "should set command" do
      runner = Mongify::CLI.new(@valid_args, nil, @output)
      runner.execute!
      runner.command.should == @valid_args[0]
    end
  end
end