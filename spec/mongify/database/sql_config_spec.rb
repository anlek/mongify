require File.join(File.dirname(File.dirname(File.dirname(File.expand_path(__FILE__)))), 'spec_helper')
require File.join(File.dirname(File.dirname(File.dirname(File.dirname(File.expand_path(__FILE__))))), 'lib', 'mongify', 'database', 'sql_config')

describe Mongify::Database::SqlConfig do
  before(:all) do
    @db_path = File.join(File.dirname(File.dirname(File.dirname(File.dirname(File.expand_path(__FILE__))))), 'spec', 'tmp', 'test.db')
    File.delete(@db_path) if File.exists?(@db_path)
    #SETUP DATABASE
    ActiveRecord::Base.establish_connection(
      :adapter => "sqlite3",
      :database => @db_path
    )

    #SETUP TABLES
    ActiveRecord::Base.connection.create_table(:users) do |t|
      t.string :first_name, :last_name
      t.timestamps
    end

    ActiveRecord::Base.connection.create_table(:posts) do |t|
      t.string :title
      t.integer :owner_id
      t.text :body
      t.datetime :published_at
      t.timestamps
    end

    ActiveRecord::Base.connection.create_table(:comments) do |t|
      t.text :body
      t.integer :post_id
      t.integer :user_id
      t.timestamps
    end
  end

  before(:each) do
    @sql_config = Mongify::Database::SqlConfig.new(:adapter => 'sqlite3', :database => @db_path)
  end

  context "Sqlite 3 config" do
    before(:each) do
      @adapter = 'sqlite'
      @database = @db_path
      @sql_config = Mongify::Database::SqlConfig.new(:adapter => @adapter, :database => @database)
    end

    context "valid?" do
      it "should be true" do
        @sql_config.should be_valid
      end
    end

    context "testing connection" do
      it "should work" do
        @sql_config.should have_connection
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
      @sql_config = Mongify::Database::SqlConfig.new(:adapter => @adapter, :host => @host, :database => @database, :username => @username, :password => @password, :port => @port)
    end

    context "valid?" do
      it "should be true" do
        Mongify::Database::SqlConfig.new(:adapter => 'mysql', :host => 'localhost', :database => 'blue').should be_valid
      end
      it "should be false" do
        Mongify::Database::SqlConfig.new(:adapter => 'mysql').should_not be_valid
      end
    end

    context "testing connection" do
      it "should call setup_connection_adapter before testing connection" do
        @sql_config.should_receive(:setup_connection_adapter)
        @sql_config.has_connection?
      end

      it "should work" do
        @sql_config.should have_connection
      end
    end
  end

  context "Sqlite connection" do
    context "testing connection" do
      it "should call setup_connection_adapter before testing connection" do
        @sql_config.should_receive(:setup_connection_adapter)
        @sql_config.has_connection?
      end

      it "should work" do
        @sql_config.should have_connection
      end
    end

    context "tables" do
      it "should be able to get a list" do
        @sql_config.get_tables.sort.should == ['comments', 'posts', 'users'].sort
      end
    end

    context "columns" do
      it "should see columns for a table" do
        @sql_config.columns_for(:users).map{ |column| column.name }.sort.should == ['id', 'first_name', 'last_name', 'created_at', 'updated_at'].sort
      end
    end

  end




end

