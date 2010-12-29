module Mongify
  module Database
    #
    # Sql connection configuration
    #
    class SqlConnection < Mongify::Database::BaseConnection

      REQUIRED_FIELDS = %w{host adapter database}

      def setup_connection_adapter
        @connection_adapter ||= ActiveRecord::Base.establish_connection(self.to_hash) unless sqlite_adapter?
      end

      def valid?
        return false unless @adapter
        case @adapter
        when 'sqlite'
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
        @adapter && @adapter.downcase == 'sqlite'
      end
    end
  end
end