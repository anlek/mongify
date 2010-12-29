require 'spec_helper'

describe Mongify::Database::SqlConnection do
  before(:all) do
    @db_path = GenerateDatabase.run
  end

  before(:each) do
    @sql_connection = Mongify::Database::SqlConnection.new(:adapter => 'sqlite3', :database => @db_path)
  end

  context "Sqlite 3 config" do
    before(:each) do
      @adapter = 'sqlite'
      @database = @db_path
      @sql_connection = Mongify::Database::SqlConnection.new(:adapter => @adapter, :database => @database)
    end

    context "valid?" do
      it "should be true" do
        @sql_connection.should be_valid
      end
    end

    context "testing connection" do
      it "should work" do
        @sql_connection.should have_connection
      end
    end
  end

  context "MySql config" do
    before(:each) do
      @adapter = 'mysql'
      @host = CONNECTION_CONFIG.mysql['host']
      @database = CONNECTION_CONFIG.mysql['database']
      @username = CONNECTION_CONFIG.mysql['username']
      @password = CONNECTION_CONFIG.mysql['password']
      @port = CONNECTION_CONFIG.mysql['port']
      @sql_connection = Mongify::Database::SqlConnection.new(:adapter => @adapter, :host => @host, :database => @database, :username => @username, :password => @password, :port => @port)
    end

    context "valid?" do
      it "should be true" do
        Mongify::Database::SqlConnection.new(:adapter => 'mysql', :host => 'localhost', :database => 'blue').should be_valid
      end
      it "should be false" do
        Mongify::Database::SqlConnection.new(:adapter => 'mysql').should_not be_valid
      end
    end

    context "testing connection" do
      it "should call setup_connection_adapter before testing connection" do
        @sql_connection.should_receive(:setup_connection_adapter)
        @sql_connection.has_connection?
      end

      it "should work" do
        @sql_connection.should have_connection
      end
    end
  end

  context "Sqlite connection" do
    context "testing connection" do
      it "should call setup_connection_adapter before testing connection" do
        @sql_connection.should_receive(:setup_connection_adapter)
        @sql_connection.has_connection?
      end

      it "should work" do
        @sql_connection.should have_connection
      end
    end

    context "tables" do
      it "should be able to get a list" do
        @sql_connection.tables.sort.should == ['comments', 'posts', 'users'].sort
      end
    end

    context "columns" do
      it "should see columns for a table" do
        @sql_connection.columns_for(:users).map{ |column| column.name }.sort.should == ['id', 'first_name', 'last_name', 'created_at', 'updated_at'].sort
      end
    end
  end
end

