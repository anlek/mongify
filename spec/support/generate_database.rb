require 'active_record'
class GenerateDatabase
  def self.mysql_connection
    @sql_connection ||= Mongify::Database::SqlConnection.new( :adapter => CONNECTION_CONFIG.mysql['adapter'], 
                                                            :host => CONNECTION_CONFIG.mysql['host'], 
                                                            :port => CONNECTION_CONFIG.mysql['port'],
                                                            :username => CONNECTION_CONFIG.mysql['username'],
                                                            :password => CONNECTION_CONFIG.mysql['password'],
                                                            :database => CONNECTION_CONFIG.mysql['database']
                                                          )
  end
  def self.sqlite_connection
    @db_path = File.join(File.dirname(File.dirname(File.dirname(File.expand_path(__FILE__)))), CONNECTION_CONFIG.sqlite['database'])
    
    @sqlite_connecton ||= Mongify::Database::SqlConnection.new(:adapter => CONNECTION_CONFIG.sqlite['adapter'], :database => @db_path)
  end
  def self.sqlite
    File.delete(sqlite_connection.database) if File.exists?(sqlite_connection.database)

    conn = sqlite_connection.connection

    #SETUP TABLES
    conn.create_table(:users) do |t|
      t.string :first_name, :last_name
      t.timestamps
    end

    conn.create_table(:posts) do |t|
      t.string :title
      t.integer :owner_id
      t.text :body
      t.datetime :published_at
      t.timestamps
    end

    conn.create_table(:comments) do |t|
      t.text :body
      t.integer :post_id
      t.integer :user_id
      t.timestamps
    end
    
    
    sqlite_connection.database
  end
  
  def self.clear_mongodb
    mongo_connection.connection.drop_database mongo_connection.database
  end
  
  def self.mongo_connection
    @mongodb_connection ||= Mongify::Database::NoSqlConnection.new(:host => CONNECTION_CONFIG.mongo['host'],
                                                                   :port => CONNECTION_CONFIG.mongo['port'],
                                                                   :database => CONNECTION_CONFIG.mongo['database'],
                                                                   :username => CONNECTION_CONFIG.mongo['username'],
                                                                   :password => CONNECTION_CONFIG.mongo['password'])
  end
end