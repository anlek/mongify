require 'spec_helper'
describe Mongify::Database::SqlConnection do
  before(:all) do
    @db_path = DatabaseGenerator.sqlite
  end

  let(:sqlite_connection){Mongify::Database::SqlConnection.new(:adapter => 'sqlite3', :database => @db_path)}
  let(:mysql_connection){@sql_connection = DatabaseGenerator.mysql_connection}
  let(:postgresql_connection){@sql_connection = DatabaseGenerator.postgresql_connection}

  context "Sqlite 3 config" do
    context "valid?" do
      it "should be true" do
        sqlite_connection.should be_valid
      end
    end

    context "testing connection" do
      it "should work" do
        sqlite_connection.should have_connection
      end
    end
  end

  context "MySql config" do
    context "valid?" do
      it "should be true" do
        Mongify::Database::SqlConnection.new(:adapter => 'mysql', :host => 'localhost', :database => 'blue').should be_valid
      end
      it "should be false" do
        Mongify::Database::SqlConnection.new(:adapter => 'mysql').should_not be_valid
      end
    end

    context "testing connection" do
      it "should work" do
        mysql_connection.should have_connection
      end
      it "should call setup_connection_adapter before testing connection" do
        mysql_connection.should_receive(:setup_connection_adapter)
        mysql_connection.has_connection?
      end
    end
  end

  context "Postgres config" do
    context "valid?" do
      it "should be true" do
        Mongify::Database::SqlConnection.new(:adapter => 'postgresql', :host => 'localhost', :database => 'mongify_test').should be_valid
      end
      it "should be false" do
        Mongify::Database::SqlConnection.new(:adapter => 'postgresql').should_not be_valid
      end
    end

    context "testing connection" do
      it "should work" do
        postgresql_connection.should have_connection
      end
      it "should call setup_connection_adapter before testing connection" do
        postgresql_connection.should_receive(:setup_connection_adapter)
        postgresql_connection.has_connection?
      end
    end
  end

  context "Sqlite connection" do
    context "testing connection" do
      it "should call setup_connection_adapter before testing connection" do
        sqlite_connection.should_receive(:setup_connection_adapter)
        sqlite_connection.has_connection?
      end

      it "should work" do
        sqlite_connection.should have_connection
      end
    end

    context "tables" do
      it "should be able to get a list" do
        sqlite_connection.tables.should =~ %w(comments notes posts preferences users teams coaches)
      end
    end

    context "columns" do
      it "should see columns for a table" do
        sqlite_connection.columns_for(:users).map{ |column| column.name }.should =~ ['id', 'first_name', 'last_name', 'created_at', 'updated_at']
      end
    end
  end

  context "select_all" do
    it "should generate correct select statement" do
      @mock_conn = double
      @mock_conn.should_receive(:select_all).with('SELECT * FROM users')
      sqlite_connection.stub(:connection).and_return(@mock_conn)
      sqlite_connection.select_rows('users')
    end
  end

  context "select_by_query" do
    it "should select rows based on a query" do
      query = "SELECT * FROM users WHERE true"
      @mock_conn = double
      @mock_conn.should_receive(:select_all).with(query)
      sqlite_connection.stub(:connection).and_return(@mock_conn)
      sqlite_connection.select_by_query(query)
    end
  end

  context "count" do
    it "should get count of all rows in a table" do
      query = "SELECT COUNT(*) FROM users"
      @mock_conn = double
      @mock_conn.should_receive(:select_value).with(query)
      sqlite_connection.stub(:connection).and_return(@mock_conn)
      sqlite_connection.count('users')
    end

    it "should get count of rows in a table filtered by a query" do
      query = "SELECT COUNT(*) FROM users WHERE true"
      @mock_conn = double
      @mock_conn.should_receive(:select_value).with(query)
      sqlite_connection.stub(:connection).and_return(@mock_conn)
      sqlite_connection.count('users', 'true')
    end
  end

  context "execute" do
    it "should execute an arbitrary query" do
      query = "CREATE TABLE x(int y);"
      @mock_conn = double
      @mock_conn.should_receive(:execute).with(query)
      sqlite_connection.stub(:connection).and_return(@mock_conn)
      sqlite_connection.execute(query)
    end
  end
end

