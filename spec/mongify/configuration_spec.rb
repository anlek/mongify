require "spec_helper"

describe Mongify::Configuration do
  before(:each) do
    Mongify::Translation.stub(:parse)
    @translation_file = File.expand_path(File.dirname(__FILE__) + '/../files/empty_translation.rb')
    @configuration_file = File.expand_path(File.dirname(__FILE__) + '/../files/base_configuration.rb')
  end
  it "should parse file for transaltion" do
    Mongify::Translation.should_receive(:parse).and_return(true)
    Mongify::Configuration.parse_translation(@translation_file)
  end

  context "configuration file" do
    it "should parse confg file" do
      Mongify::Configuration.should_receive(:parse).and_return(true)
      Mongify::Configuration.parse_configuration(@configuration_file)
    end

    it "should validate file exists" do
      lambda { Mongify::Configuration.parse_configuration("../missing_file.rb") }.should raise_error(Mongify::FileNotFound)
    end

    context "load database config" do
      context "sql" do
        it "should load" do
          Mongify::Database::SqlConnection.should_receive(:new)
          Mongify::Configuration.parse_configuration(@configuration_file)
        end
      end

      context "nosql" do
        it "should load" do
          Mongify::Database::NoSqlConnection.should_receive(:new)
          Mongify::Configuration.parse_configuration(@configuration_file)
        end
      end
    end

  end
end
