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
    @adapter = 'mysql'
    @host = '127.0.0.1'
    @database = 'test_database'
    @sql_config = Mongify::Database::SqlConfig.new
  end
  
  context "valid?" do
    it "should be true" do
      Mongify::Database::SqlConfig.new(:adapter => 'mysql', :host => 'localhost', :database => 'blue').should be_valid
    end
    it "should be false" do
      Mongify::Database::SqlConfig.new.should_not be_valid
    end
  end
  
  
  context "testing connection" do
    before(:each) do
      @sql_config = Mongify::Database::SqlConfig.new(:adapter => @adapter, :host => @host, :database => @database)
    end
    
    it "should call setup_connection_adapter before testing connection" do
      @sql_config.should_receive(:setup_connection_adapter)
      @sql_config.has_connection?
    end

    it "should work" do
      @sql_config.should have_connection
    end
  end

  context "tables" do
    before(:each) do
      @sql_config = Mongify::Database::SqlConfig.new(:adapter => 'sqlite3', :database => @db_path) 
    end
    it "should be able to get a list" do
      @sql_config.get_tables.sort.should == ['comments', 'posts', 'users'].sort
    end
  end
  
  
end

