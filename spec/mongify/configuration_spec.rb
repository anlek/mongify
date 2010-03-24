require File.dirname(__FILE__) + '/../spec_helper'

describe Mongify::Configuration do
  before(:each) do
    Mongify::Translation.stubs(:parse)
    @file_path = File.expand_path(File.dirname(__FILE__) + '/../files/empty_translation.rb')
  end
  it "should parse file for transaltion" do
    Mongify::Translation.expects(:parse).returns(true)
    Mongify::Configuration.parse_file(@file_path)
  end
  
  it "should validate file exists" do
    lambda { Mongify::Configuration.parse_file("../missing_file.rb") }.should raise_error
  end
end