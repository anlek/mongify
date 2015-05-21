require 'spec_helper'

describe Mongify do
  describe :root do
    it "should be settable" do
      Mongify.root = Dir.pwd
      Mongify.root.should == Dir.pwd
    end

    it "should raise error if not defined" do
      Mongify.root = nil
      lambda { Mongify.root }.should raise_error(Mongify::RootMissing)
    end
  end
end
