require 'spec_helper'

describe Mongify::UI do
  before(:each) do
    @ui = Mongify::UI
    @config = Mongify::Configuration
    @out = StringIO.new
    @in = StringIO.new
    @config.out_stream = @out
    @config.in_stream = @in
  end

  it "should add puts to out stream" do
    @ui.puts "hello"
    @out.string.should == "hello\n"
  end

  it "should add print to out stream without newline" do
    @ui.print "hello"
    @out.string.should == "hello"
  end

  it "should fetch gets from in stream" do
    @in.puts "bar"
    @in.rewind
    @ui.gets.should == "bar\n"
  end

  it "should gets should return empty string if no input" do
    @config.in_stream = nil
    @ui.gets.should == ""
  end

  it "should request text input" do
    @in.puts "bar"
    @in.rewind
    @ui.request("foo").should == "bar"
    @out.string.should == "foo"
  end

  it "should ask for yes/no and return true when yes" do
    @ui.should_receive(:request).with('foo? [yn] ').and_return('y')
    @ui.ask("foo?").should be_truthy
  end

  it "should ask for yes/no and return false when no" do
    @ui.stub(:request).and_return('n')
    @ui.ask("foo?").should be_falsey
  end

  it "should ask for yes/no and return false for any input" do
    @ui.stub(:request).and_return('aklhasdf')
    @ui.ask("foo?").should be_falsey
  end

  it "should add WARNING to a warn message" do
    @ui.warn "hello"
    @out.string.should == "WARNING: hello\n"
  end

  context "terminal_helper" do
    it "should return a HighLine class" do
      @ui.terminal_helper.should be_a_kind_of HighLine
    end
  end

  context "abort" do
    it "should abort program execution" do
      Kernel.should_receive(:abort)
      @ui.abort "hacker!"
    end

    it "should output message" do
      Kernel.stub(:abort)
      @ui.abort "hacker!"
      @out.string.should == "PROGRAM HALT: hacker!\n"
    end
  end
end
