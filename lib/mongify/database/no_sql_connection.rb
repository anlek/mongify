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
    #   ssl
    #   auth_source
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

      def ssl?
        !!ssl
      end

      # Sets up a connection to the database
      def setup_connection_adapter
        options = { database: database, ssl: ssl? }
        options = add_auth(options, username, password, auth_source)
        if host.nil?
          addresses = ["#{host}:#{port}"]
        else
          @port ||= 27017
          addresses = host.split(",").map { |h| "#{h}:#{@port}" }
        end
        Mongo::Client.new(addresses, options)
      end

      def add_auth(options, username, password, auth_source)
        if username && password
          options[:user] = username
          options[:password] = password
          options[:auth_source] = auth_source || 'admin'
        end
        options
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
        # this is a hack - mongo v1 exposed a connected? method
        # this is no longer true for mongo v2
        # however, mongo.list_databases will throw an exception if not connected
        # known issue with this -- if user has no permission to list databases,
        # this will throw an error even if connected
        begin
          connection.list_databases
        rescue
          return false
        end

        return true
      end

      # Returns the database from the connection
      def db
        @db ||= connection.database
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
        db[colleciton_name].insert_many(row)
      end

      # Updates a collection item with a given ID with the given attributes
      def update(colleciton_name, id, attributes)
        db[colleciton_name].update_one({"_id" => id}, attributes)
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
        db[collection_name].find(query).try(:first)
      end

      # Returns a row of a item from a given collection with a given pre_mongified_id
      def get_id_using_pre_mongified_id(colleciton_name, pre_mongified_id)
        db[colleciton_name].find('pre_mongified_id' => pre_mongified_id).try(:[], '_id')
      end

      # Removes pre_mongified_id from all records in a given collection
      def remove_pre_mongified_ids(collection_name)
        drop_mongified_index(collection_name)
        db[collection_name].update_many({}, { '$unset' => { 'pre_mongified_id' => 1} })
      end

      # Removes pre_mongified_id from collection
      # @param [String] collection_name name of collection to remove the index from
      # @return True if successful
      # @raise MongoDBError if index isn't found
      def drop_mongified_index(collection_name)
        db[collection_name].indexes.drop_one('pre_mongified_id_1') unless db[collection_name].indexes.get('pre_mongified_id_1').nil?
      end

      # Creates a pre_mongified_id index to ensure
      # speedy lookup for collections via the pre_mongified_id
      def create_pre_mongified_id_index(collection_name)
        db[collection_name].indexes.create_many([ { key: { pre_mongified_id: 1 } } ])
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
