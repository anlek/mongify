require File.dirname(__FILE__) + '/../spec_helper'

describe Mongify::Runner do
  before(:each) do
    @output = mock('output')
    @output.stubs(:puts)
    @valid_args = ['check', 'spec/files/empty_translation.rb']
  end
  
  it "should run and finish fully" do
    @output.expects(:puts).with('[DONE]')
    lambda{ Mongify::Runner.new(@valid_args, nil, @output).run }.should_not raise_error
  end
  
  context "Validation" do
    it "should not take 1 argument" do
      @valid_args.pop
      lambda {Mongify::Runner.new(@valid_args, nil, @output).run}.should raise_error(SystemExit)
    end
    
    it "should not take 3 arguemnts" do
      @valid_args << 'unexceptable'
      lambda {Mongify::Runner.new(@valid_args, nil, @output).run}.should raise_error(SystemExit)
    end
    
    it "should check if file exists" do
      @valid_args[1] = 'spec/files/missing_translation.rb'
      lambda {Mongify::Runner.new(@valid_args, nil, @output).run}.should raise_error(SystemExit)
    end
    
    it "should check command exists" do
      @valid_args[0] = 'missing'
      lambda{Mongify::Runner.new(@valid_args, nil, @output).run}.should raise_error(SystemExit)
    end
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