require 'active_record'
class GenerateDatabase
  def self.run
    @db_path = File.join(File.dirname(File.dirname(File.dirname(File.expand_path(__FILE__)))), CONNECTION_CONFIG.sqlite['database'])
    
    File.delete(@db_path) if File.exists?(@db_path)
    #SETUP DATABASE
    ActiveRecord::Base.establish_connection(
      :adapter => CONNECTION_CONFIG.sqlite['adapter'],
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
    
    @db_path
  end
end