require 'spec_helper'

describe Mongify::CLI::Application do
  context "execute!" do
    it "should return a 0" do
      @application = Mongify::CLI::Application.new()
      Mongify::Configuration.out_stream = nil
      @application.execute!.should == 0
    end

    it "should return a 1 on error" do
      @application = Mongify::CLI::Application.new(["door"])
      Mongify::Configuration.out_stream = nil
      @application.execute!.should == 1
    end
  end

end
