require 'mongo'
module Mongify
  module Database
    #
    # No sql connection configuration
    #
    class NoSqlConnection < Mongify::Database::BaseConnection
      include Mongo
      REQUIRED_FIELDS = %w{host database}  
      
      def initialize(options=nil)
        super options
        adapter 'mongodb' if adapter.nil? || adapter == 'mongo'
      end
      
      def connection_string
        "#{@adapter}://#{@host}#{":#{@port}" if @port}"
      end
      
      def valid?
        @database.present? && @host.present?
      end
      
      def connection
        return @connection if @connection
        @connection = Connection.new(host, port)
        @connection.add_auth(database, username, password) if username && password
        @connection
      end
      
      def has_connection?
        connection.connected?
      end
      
      def db
        @db ||= connection[database]
      end
      
      
      def reset!
        @connection = nil
        @db = nil
      end
    end
  end
end