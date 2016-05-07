require 'spec_helper'

describe Mongify::CLI::Command::Worker do
  before(:each) do
    @config = Mongify::Configuration.new()
    @sql_connection = Mongify::Database::SqlConnection.new()
    @sql_connection.stub(:valid?).and_return(true)
    @sql_connection.stub(:has_connection?).and_return(true)
    @config.stub(:sql_connection).and_return(@sql_connection)
    @no_sql_connection = Mongify::Database::NoSqlConnection.new
    @no_sql_connection.stub(:valid?).and_return(true)
    @no_sql_connection.stub(:has_connection?).and_return(true)
    @config.stub(:no_sql_connection).and_return(@no_sql_connection)

    @translation_file = 'spec/files/translation.rb'

    Mongify::Translation.stub(:load).and_return(double(:print => 'worked'))
    @view = double('view').as_null_object
  end

  context "list_commands" do
    it "should return same number as available" do
      Mongify::CLI::Command::Worker.list_commands.size.should == Mongify::CLI::Command::Worker::AVAILABLE_COMMANDS.size
    end
  end

  context "check command" do
    before(:each) do
      @command = Mongify::CLI::Command::Worker.new('check', @config)
      @command.stub(:check_sql_connection).and_return(true)
      @command.stub(:check_nosql_connection).and_return(true)
    end
    it "should ensure sql_connection is correct" do
      @command.should_receive(:check_sql_connection).and_return(true)
      @command.execute(@view)
    end
    it "should ensure noSql connection is correct" do
      @command.should_receive(:check_nosql_connection).and_return(true)
      @command.execute(@view)
    end
    it "should require config file" do
      lambda { @command = Mongify::CLI::Command::Worker.new('check').execute(@view) }.should raise_error(Mongify::ConfigurationFileNotFound)
    end
  end

  context "non-existing command" do
     before(:each) do
      @command = Mongify::CLI::Command::Worker.new('unknown')
    end

    it "should report error" do
      @view.should_receive(:report_error)
      @command.execute(@view)
    end

    it "should output an error" do
      @view.should_receive(:output).with("Unknown action unknown\n\n")
      @command.execute(@view)
    end
  end

  context "translation command" do
    before(:each) do
      @command = Mongify::CLI::Command::Worker.new('translation', @config)
      Mongify::Translation.stub(:load).with(@sql_connection).and_return(double(:print => 'worked'))
    end

    it "should require configuration file" do
      lambda { Mongify::CLI::Command::Worker.new('translation').execute(@view) }.should raise_error(Mongify::ConfigurationFileNotFound)
    end

    it "should check sql connection" do
      @command.should_receive(:check_sql_connection).and_return(true)
      @command.execute(@view)
    end

    it "should call load on Translation" do
      Mongify::Translation.should_receive(:load).with(@sql_connection).and_return(double(:print => 'worked'))
      @command.execute(@view)
    end
  end

  context "process command" do
    before(:each) do
      @command = Mongify::CLI::Command::Worker.new('process', @config, 'spec/files/translation.rb')
      Mongify::Translation.stub(:parse).and_return(double(:process => true))
    end
    it "should report success" do
      @view.should_receive(:report_error).never
      @view.should_receive(:report_success)
      @command.execute(@view)
    end

    it "should require config file" do
      lambda { @command = Mongify::CLI::Command::Worker.new('process').execute(@view) }.should raise_error(Mongify::ConfigurationFileNotFound)
    end

    it "should require transaction file" do
      lambda { @command = Mongify::CLI::Command::Worker.new('process', @config).execute(@view) }.should raise_error(Mongify::TranslationFileNotFound)
    end

    it "should check_connection" do
      @command.should_receive(:check_connections).and_return(true)
      @command.execute(@view)
    end

    it "should call process on translation" do
      Mongify::Translation.should_receive(:parse).and_return(double(:process => true))
      @command.execute(@view)
    end
  end

  context "sync command" do
    before(:each) do
      @command = Mongify::CLI::Command::Worker.new('sync', @config, 'spec/files/translation.rb')
      Mongify::Translation.stub(:parse).and_return(double(:sync => true))
    end
    it "should report success" do
      @view.should_receive(:report_error).never
      @view.should_receive(:report_success)
      @command.execute(@view)
    end

    it "should require config file" do
      lambda { @command = Mongify::CLI::Command::Worker.new('sync').execute(@view) }.should raise_error(Mongify::ConfigurationFileNotFound)
    end

    it "should require transaction file" do
      lambda { @command = Mongify::CLI::Command::Worker.new('sync', @config).execute(@view) }.should raise_error(Mongify::TranslationFileNotFound)
    end

    it "should check_connection" do
      @command.should_receive(:check_connections).and_return(true)
      @command.execute(@view)
    end

    it "should call sync on translation" do
      Mongify::Translation.should_receive(:parse).and_return(double(:sync => true))
      @command.execute(@view)
    end
  end

end
