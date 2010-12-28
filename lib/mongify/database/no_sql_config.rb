require File.join(File.dirname(File.expand_path(__FILE__)), 'base_config')

module Mongify
  module Database
    #
    # No sql connection configuration
    #
    class NoSqlConfig < Mongify::Database::BaseConfig
          
      REQUIRED_FIELDS = %w{host database}  
      
      def initialize(options=nil)
        super options
        @adapter = 'mongo'
      end
      
      def collection=(value)
        @database = value
      end
      
      def connection_string
        if(@username && @password)
          "#{@adapter}://#{@username}:#{@password}@#{@host}/#{@database}"
        else
          "#{@adapter}://#{@host}/#{@database}"
        end
      end
      
    end
  end
end