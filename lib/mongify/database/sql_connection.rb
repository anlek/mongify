module Mongify
  module Database
    #
    # Sql connection configuration
    #
    class SqlConnection < Mongify::Database::BaseConnection

      REQUIRED_FIELDS = %w{host adapter database}
      
      def initialize(options=nil)
        @prefixed_db = false
        super(options)
      end

      def setup_connection_adapter
        ActiveRecord::Base.establish_connection(self.to_hash)
      end

      def valid?
        return false unless @adapter
        if sqlite_adapter?
          return true if @database
        else
          return super
        end
        false
      end

      def tables
        return nil unless has_connection?
        ActiveRecord::Base.connection.tables
      end

      def columns_for(table_name)
        ActiveRecord::Base.connection.columns(table_name)
      end

      def has_connection?
        setup_connection_adapter
        ActiveRecord::Base.connection.send(:connect) if ActiveRecord::Base.connection.respond_to?(:connect)
        true
      end

      #######
      private
      #######
      def sqlite_adapter?
        @adapter && (@adapter.downcase == 'sqlite' || @adapter.downcase == 'sqlite3')
      end
    end
  end
end