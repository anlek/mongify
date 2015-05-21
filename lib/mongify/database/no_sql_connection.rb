require 'mongo'
module Mongify
  module Database
    #
    # No Sql Connection configuration
    #
    # Basic format should look something like this:
    #
    #   no_sql_connection {options} do
    #     adapter   "mongodb"
    #     host      "localhost"
    #     database  "my_database"
    #   end
    #
    # Possible attributes:
    #   adapter
    #   host
    #   database
    #   username
    #   password
    #   port
    #
    # Options:
    #   :force => true       # This will force a database drop before processing
    # <em>You're also able to set attributes via the options</em>
    #
    class NoSqlConnection < Mongify::Database::BaseConnection
      include Mongo


      #Required fields for a no sql connection
      REQUIRED_FIELDS = %w{host database}

      def initialize(options={})
        super options
        @options = options
        adapter 'mongodb' if adapter.nil? || adapter.downcase == "mongo"
      end

      # Sets and/or returns a adapter
      # It takes care of renaming adapter('mongo') to 'mongodb'
      def adapter(name=nil)
        super(name)
      end

      # Returns a connection string that can be used to build a Mongo Connection
      # (Currently this isn't used due to some issue early on in development)
      def connection_string
        "#{@adapter}://#{@host}#{":#{@port}" if @port}"
      end

      # Returns true or false depending if the given attributes are present and valid to make up a
      # connection to a mongo server
      def valid?
        super && @database.present?
      end

      # Returns true if :force was set to true
      # This will force a drop of the database upon connection
      def forced?
        !!@options['force']
      end

      # Sets up a connection to the database
      def setup_connection_adapter
        connection = Connection.new(host, port)
        connection.add_auth(database, username, password) if username && password
        connection
      end

      # Returns a mongo connection
      # NOTE: If forced? is true, the first time a connection is made, it will ask to drop the
      # database before continuing
      def connection
        return @connection if @connection
        @connection = setup_connection_adapter
        @connection
      end

      # Returns true or false depending if we have a connection to a mongo server
      def has_connection?
        connection.connected?
      end

      # Returns the database from the connection
      def db
        @db ||= connection[database]
      end

      # Returns a hash of all the rows from the database of a given collection
      def select_rows(collection)
        db[collection].find
      end

      def select_by_query(collection, query)
        db[collection].find(query)
      end

      # Inserts into the collection a given row
      def insert_into(colleciton_name, row)
        db[colleciton_name].insert(row)
      end

      # Updates a collection item with a given ID with the given attributes
      def update(colleciton_name, id, attributes)
        db[colleciton_name].update({"_id" => id}, attributes)
      end

      # Upserts into the collection a given row
      def upsert(collection_name, row)
        # We can't use the save method of the Mongo collection
        # The reason is that it detects duplicates using _id
        # but we should detect it using pre_mongified_id instead
        # because in the case of sync, same rows are identified by their original sql ids
        #
        # db[collection_name].save(row)

        if row.has_key?(:pre_mongified_id) || row.has_key?('pre_mongified_id')
          id = row[:pre_mongified_id] || row['pre_mongified_id']
          duplicate = find_one(collection_name, {"pre_mongified_id" => id})
          if duplicate
            update(collection_name, duplicate[:_id] || duplicate["_id"], row)
          else
            insert_into(collection_name, row)
          end
        else
          # no pre_mongified_id, fallback to the upsert method of Mongo
          db[collection_name].save(row)
        end
      end

      # Finds one item from a collection with the given query
      def find_one(collection_name, query)
        db[collection_name].find_one(query)
      end

      # Returns a row of a item from a given collection with a given pre_mongified_id
      def get_id_using_pre_mongified_id(colleciton_name, pre_mongified_id)
        db[colleciton_name].find_one('pre_mongified_id' => pre_mongified_id).try(:[], '_id')
      end

      # Removes pre_mongified_id from all records in a given collection
      def remove_pre_mongified_ids(collection_name)
        drop_mongified_index(collection_name)
        db[collection_name].update({}, { '$unset' => { 'pre_mongified_id' => 1} }, :multi => true)
      end

      # Removes pre_mongified_id from collection
      # @param [String] collection_name name of collection to remove the index from
      # @return True if successful
      # @raise MongoDBError if index isn't found
      def drop_mongified_index(collection_name)
        db[collection_name].drop_index('pre_mongified_id_1') if db[collection_name].index_information.keys.include?("pre_mongified_id_1")
      end

      # Creates a pre_mongified_id index to ensure
      # speedy lookup for collections via the pre_mongified_id
      def create_pre_mongified_id_index(collection_name)
        db[collection_name].create_index([['pre_mongified_id', Mongo::ASCENDING]])
      end

      # Asks user permission to drop the database
      # @return true or false depending on user's response
      def ask_to_drop_database
        if UI.ask("Are you sure you want to drop #{database} database?")
          drop_database
        end
      end

      #######
      private
      #######

      # Drops the mongodb database
      def drop_database
        connection.drop_database(database)
      end



    end
  end
end
