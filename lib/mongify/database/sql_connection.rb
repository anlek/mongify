module Mongify
  module Database
    #
    # Sql connection configuration
    #
    # 
    # Basic format should look something like this:
    # 
    #   sql_connection do
    #     adaptor   "mysql"
    #     host      "localhost"
    #     username  "root"
    #     password  "passw0rd"
    #     database  "my_database"
    #   end
    # Possible attributes:
    # 
    #   adapter
    #   host
    #   database
    #   username
    #   password
    #   port
    #   encoding
    #   socket
    # 
    class SqlConnection < Mongify::Database::BaseConnection
      
      # List of required fields to bulid a valid sql connection
      REQUIRED_FIELDS = %w{host adapter database}
      
      def initialize(options=nil)
        @prefixed_db = false
        super(options)
      end

      # Setups up an active_record connection
      def setup_connection_adapter
        ActiveRecord::Base.establish_connection(self.to_hash)
      end
      
      # Returns true or false depending if the record is valid
      def valid?
        return false unless @adapter
        if sqlite_adapter?
          return true if @database
        else
          return super
        end
        false
      end
      
      # Returns true or false depending if the connction actually talks to the database server.
      def has_connection?
        setup_connection_adapter
        connection.send(:connect) if ActiveRecord::Base.connection.respond_to?(:connect)
        true
      end
      
      # Returns the active_record connection
      def connection
        return nil unless has_connection?
        ActiveRecord::Base.connection
      end
      
      # Returns all the tables in the database server
      def tables
        return nil unless has_connection?
        self.connection.tables
      end

      # Returns all the columns for a given table
      def columns_for(table_name)
        self.connection.columns(table_name)
      end
      
      # Returns an array with hash values of all the records in a given table
      def select_rows(table_name)
        self.connection.select_all("SELECT * FROM #{table_name}")
      end

      #######
      private
      #######
      # Used to check if this is a sqlite connection 
      def sqlite_adapter?
        @adapter && (@adapter.downcase == 'sqlite' || @adapter.downcase == 'sqlite3')
      end
    end
  end
end