module Mongify
  module Database
    #
    # Sql connection configuration
    #
    #
    # Basic format should look something like this:
    #
    #   sql_connection do
    #     adapter   "mysql"
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
    #   batch_size
    #
    class SqlConnection < Mongify::Database::BaseConnection

      # List of required fields to bulid a valid sql connection
      REQUIRED_FIELDS = %w{host adapter database}
      SYNC_HELPER_TABLE = "__mongify_sync_helper__"

      def initialize(options={})
        options['batch_size'] ||= 10000
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
      def select_rows(table_name, is_sync, &block)
        return self.connection.select_all("SELECT * FROM #{table_name}") unless block_given?

        row_count = count(table_name);
        pages = (row_count.to_f/batch_size).ceil
        (1..pages).each do |page|
          rows = select_paged_rows(table_name, batch_size, page, is_sync)
          yield rows, page, pages
        end
      end

      def select_paged_rows(table_name, batch_size, page, is_sync)
        if adapter == "sqlserver"
          offset = (page - 1) * batch_size

          # TODO: sync support for sql server
          return connection.select_all(
            "SELECT * FROM
                        (
                            SELECT TOP #{offset+batch_size} *, ROW_NUMBER() OVER (ORDER BY (SELECT 1)) AS rnum
                            FROM #{table_name}
                        ) #{table_name}
                        WHERE rnum > #{offset}"
          )
        end

        q_select = "SELECT t.* FROM #{table_name} t"

        # TODO: How to handle orderby for tables that dont have an id to order by.
        q_batch = "ORDER BY id LIMIT #{batch_size} OFFSET #{(page - 1) * batch_size}"
        q_sync = "#{SYNC_HELPER_TABLE} u WHERE t.updated_at > u.last_updated_at AND u.table_name = '#{table_name} '"

        q = q_select + ', ' + q_batch
        if is_sync
            q = q_select + ', ' + q_sync + ' ' + q_batch
        end

        connection.select_all(q)
      end

      # Returns an array with hash values of the records in a given table specified by a query
      def select_by_query(query)
        self.connection.select_all(query)
      end

      def count(table_name, where = nil)
        q = "SELECT COUNT(*) FROM #{table_name}"
        q = "#{q} WHERE #{where}" if where
        self.connection.select_value(q).to_i
      end

      def execute(query)
        self.connection.execute(query)
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
