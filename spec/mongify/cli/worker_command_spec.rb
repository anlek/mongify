require 'spec_helper'

describe Mongify::CLI::WorkerCommand do
  before(:each) do
    @config = Mongify::Configuration.new()
    @sql_connection = Mongify::Database::SqlConnection.new()
    @sql_connection.stub(:valid?).and_return(true)
    @sql_connection.stub(:has_connection?).and_return(true)
    @config.stub(:sql_connection).and_return(@sql_connection)
    @no_sql_connection = stub(Mongify::Database::NoSqlConnection, :valid? => true, :has_connection? => true)
    @config.stub(:no_sql_connection).and_return(@no_sql_connection)
    
    Mongify::Translation.stub(:load).and_return(stub(:print => 'worked'))
    @view = mock('view').as_null_object
  end
  
  context "list_commands" do
    it "should return same number as available" do
      Mongify::CLI::WorkerCommand.list_commands.size.should == Mongify::CLI::WorkerCommand::AVAILABLE_COMMANDS.size
    end
  end
  
  context "check command" do
    before(:each) do
      @command = Mongify::CLI::WorkerCommand.new('check')
    end
    it "should ensure sql_connection is correct" do
      @command.should_receive(:check_sql_connection).and_return(true)
      @command.execute(@view)
    end
    it "should ensure noSql connection is correct" do
      @command.stub(:check_sql_connection).and_return(true)
      @command.should_receive(:check_nosql_connection).and_return(true)
      @command.execute(@view)
    end
  end
  
  context "non-existing command" do
     before(:each) do
      @command = Mongify::CLI::WorkerCommand.new('unknown')
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

  context "translate command" do
    before(:each) do
      @command = Mongify::CLI::WorkerCommand.new('translation', @config)
    end
    
    it "should check sql connection" do
      @command.should_receive(:check_sql_connection).and_return(true)
      @command.execute(@view)
    end
    
    it "should call load on Translation" do
      Mongify::Translation.should_receive(:load).with(@sql_connection).and_return(stub(:print => 'worked'))
      @command.execute(@view)
    end
  end
end
