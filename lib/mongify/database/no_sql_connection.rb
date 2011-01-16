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
      
      def select_rows(collection)
        db[collection].find
      end
      
      def insert_into(colleciton_name, row)
        db[colleciton_name].insert(row, :safe => true)
      end
      
      def update(colleciton_name, id, attributes)
        db[colleciton_name].update({"_id" => id}, attributes)
      end
      
      def find_one(collection_name, query)
        db[collection_name].find_one(query)
      end
      
      def get_id_using_pre_mongified_id(colleciton_name, pre_mongified_id)
        db[colleciton_name].find_one('pre_mongified_id' => pre_mongified_id).try(:[], '_id')
      end
      
      
      def reset!
        @connection = nil
        @db = nil
      end
    end
  end
end