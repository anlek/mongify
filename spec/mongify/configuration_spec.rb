require "spec_helper"

describe Mongify::Configuration do
  before(:each) do
    @configuration_file = File.expand_path(File.dirname(__FILE__) + '/../files/base_configuration.rb')
  end

  context "parse" do
    it "should parse correctly" do
      c = Mongify::Configuration.parse(@configuration_file)
      c.sql_connection.should be_valid
      c.no_sql_connection.should be_valid
    end
    it "should validate file exists" do
      lambda { Mongify::Configuration.parse("../missing_file.rb") }.should raise_error(Mongify::FileNotFound)
    end

  end
end
