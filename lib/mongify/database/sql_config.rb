require File.join(File.dirname(File.expand_path(__FILE__)), 'base_config')

module Mongify
  module Database
    #
    # Sql connection configuration
    #
    class SqlConfig < Mongify::Database::BaseConfig
          
      REQUIRED_FIELDS = %w{host adaptor database}  
      
      def connection_string
        if(@username && @password)
          "#{@adaptor}://#{@username}:#{@password}@#{@host}/#{@database}"
        else
          "#{@adaptor}://#{@host}/#{@database}"
        end
      end
      
      def connects?
        #TODO: there must be a better way
        begin
          dm_connection.execute("select 1")
        rescue
          return false
        end
        true
      end
      
    end
  end
end