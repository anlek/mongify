require 'spec_helper'

describe Mongify::CLI::Application do
  before(:each) do
    @application = Mongify::CLI::Application.new()
  end

  context "execute!" do
    it "should return a 0" do
      @application.execute!.should == 0
    end
    
    it "should return a 1 on error" do
      @application = Mongify::CLI::Application.new(["door"])
      @application.execute!.should == 1
    end
  end

end
