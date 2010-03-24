require File.dirname(__FILE__) + '/../spec_helper'

describe Mongify::Translation do
  before(:each) do
    @file_path = File.expand_path(File.dirname(__FILE__) + '/../files/simple_translation.rb')
  end
  it "should read in file" do
    translation = Mongify::Translation.parse(@file_path)
  end
end
