module Mongify
  module Database
    #
    # No sql connection configuration
    #
    class NoSqlConnection < Mongify::Database::BaseConnection
          
      REQUIRED_FIELDS = %w{host database}  
      
      def initialize(options=nil)
        super options
        @adapter = 'mongo'
      end
      
      def collection(value=nil)
        @database ||= value
        @database
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