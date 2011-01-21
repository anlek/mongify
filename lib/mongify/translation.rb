require 'mongify/translation/printer'
require 'mongify/translation/process'
module Mongify
  #
  # Actually runs the translation from sql to no sql
  #
  # Basic translation file should look like this:
  #   table "users" do
  #     column "id", :key
  #     column "first_name", :string
  #     column "last_name", :string
  #     column "created_at", :datetime
  #     column "updated_at", :datetime
  #   end
  #   
  #   table "posts" do
  #     column "id", :key
  #     column "title", :string
  #     column "owner_id", :integer, :references => :users
  #     column "body", :text
  #     column "published_at", :datetime
  #     column "created_at", :datetime
  #     column "updated_at", :datetime
  #   end
  #   
  #   table "comments", :embed_in => :posts, :on => :post_id do
  #     column "id", :key
  #     column "body", :text
  #     column "post_id", :integer, :referneces => :posts
  #     column "user_id", :integer, :references => :users
  #     column "created_at", :datetime
  #     column "updated_at", :datetime
  #   end
  #   
  #   table "preferences", :embed_in => :users, :as => :object do
  #     column "id", :key
  #     column "user_id", :integer, :references => "users"
  #     column "notify_by_email", :boolean
  #   end
  class Translation
    include Printer
    include Process
    class << self
      # Returns an instance of a translation object
      # Takes a location of a translation file
      def parse(file_name)
        translation = self.new
        translation.instance_eval(File.read(file_name))
        translation
      end
      
      #Returns an instence of a translation object with a given sql connection layout loaded
      def load(connection)
        raise Mongify::SqlConnectionRequired, "Can only read from Mongify::Database::SqlConnection" unless connection.is_a?(Mongify::Database::SqlConnection)
        return unless connection.valid? && connection.has_connection?
        translation = self.new
        connection.tables.each do |t|
          columns = []
          connection.columns_for(t).each do |ar_col|
            columns << Mongify::Database::Column.new(ar_col.name, ar_col.type, :auto_detect => true)
          end
          translation.table(t, :columns => columns)
        end
        translation
      end
    end
    
    def initialize
      @all_tables = []
    end
    
    # Creates a {Mongify::Database::Table} from the given input and adds it to the list of tables
    def table(table_name, options={}, &block)
      table = Mongify::Database::Table.new(table_name, options, &block)
      add_table(table)
    end
    
    # Adds a {Mongify::Database::Table} to the list of tables
    def add_table(table)
      @all_tables << table
      table
    end
    
    # Returns an array of all tables in the translation
    def all_tables
      @all_tables
    end
    
    # Returns an array of all tables that have not been ingored
    def tables
      all_tables.reject{ |t| t.ignored? }
    end
    
    # Returns an array of all tables that have not been ignored and are just straight copy tables
    def copy_tables
      tables.reject{|t| t.embed?}
    end
    
    # Returns an array of all tables that have not been ignored and are to be embedded
    def embed_tables
      tables.reject{|t| !t.embed?}
    end
    
  end
end
