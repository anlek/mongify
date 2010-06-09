require File.join(File.dirname(File.expand_path(__FILE__)), 'base_config')

module Mongify
  module Database
    #
    # Sql connection configuration
    #
    class SqlConfig < Mongify::Database::BaseConfig
          
      REQUIRED_FIELDS = %w{host adapter database}  
      
      def connection_adapter
        @connection_adapter ||= ActiveRecord::Base.establish_connection(self.to_hash)
      end
      
      
      def connects?
        #TODO: there must be a better way
        begin
          connection_adapter.connect
        rescue Exception => e
          puts "Error: #{e}"
          return false
        end
        true
      end
      
    end
  end
end