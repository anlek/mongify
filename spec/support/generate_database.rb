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
  def self.sqlite(include_data=true)
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
    
    conn.create_table(:preferences) do |t|
      t.integer :user_id
      t.boolean :notify_by_email
      t.timestamps
    end
    
    if include_data
      
      #Users
      [ 
        {:first_name => 'Timmy', :last_name => 'Zuza'},
        {:first_name => 'Bob', :last_name => 'Smith'},
        {:first_name => 'Joe', :last_name => 'Franklin'}
      ].each do |values|
        conn.insert("INSERT INTO users (first_name, last_name, created_at, updated_at) VALUES ('#{values[:first_name]}', '#{values[:last_name]}', '#{Time.now.to_s(:db)}', '#{Time.now.to_s(:db)}')")
      end
      
      #Posts
      [ 
        {:title => 'First Post', :owner_id => 1, :body => 'First Post Body', :published_at => (Time.now - 2).to_s(:db)},
        {:title => 'Second Post', :owner_id => 1, :body => 'Second Post Body', :published_at => (Time.now - 1).to_s(:db)},
        {:title => 'Third Post', :owner_id => 2, :body => 'Thrid Post Body', :published_at => (Time.now).to_s(:db)},
      ].each do |v|
        conn.insert("INSERT INTO posts (title, owner_id, body, published_at, created_at, updated_at) 
                    VALUES ('#{v[:title]}', #{v[:owner_id]}, '#{v[:body]}', '#{v[:published_at]}', '#{Time.now.to_s(:db)}', '#{Time.now.to_s(:db)}')")
      end
      
      #Comments
      [
        {:post_id => 1, :user_id => 1, :body => 'First Comment Body'},
        {:post_id => 2, :user_id => 1, :body => 'Second Comment Body'},
        {:post_id => 2, :user_id => 2, :body => 'Thrid Comment Body'}
      ].each do |v|
        conn.insert("INSERT INTO comments (body, post_id, user_id, created_at, updated_at) 
                    VALUES ('#{v[:body]}', #{v[:post_id]}, #{v[:user_id]}, '#{Time.now.to_s(:db)}', '#{Time.now.to_s(:db)}')")
      end
      
      [
        {:user_id => 1, :notify_by_email => true},
        {:user_id => 2, :notify_by_email => true},
        {:user_id => 3, :notify_by_email => false}
      ].each do |v|
          conn.insert("INSERT INTO preferences (user_id, notify_by_email, created_at, updated_at) 
                      VALUES (#{v[:user_id]}, '#{v[:notify_by_email]}', '#{Time.now.to_s(:db)}', '#{Time.now.to_s(:db)}')")
      end
      
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