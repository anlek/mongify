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

      # Sets up a connection to the database using Mongo::Client (2.x driver)
      def setup_connection_adapter
        hosts = ["#{host}:#{port || 27017}"]
        client_options = { database: database }

        if username && password
          client_options[:user] = username
          client_options[:password] = password
        end

        Mongo::Client.new(hosts, client_options)
      end

      # Returns a mongo client connection
      # NOTE: If forced? is true, the first time a connection is made, it will ask to drop the
      # database before continuing
      def connection
        return @connection if @connection
        @connection = setup_connection_adapter
        @connection
      end

      # Alias for connection to make code more readable with 2.x driver
      alias_method :client, :connection

      # Returns true or false depending if we have a connection to a mongo server
      def has_connection?
        # In mongo 2.x, we ping the server to check connectivity
        begin
          client.database.command(ping: 1)
          true
        rescue Mongo::Error => e
          false
        end
      end

      # Returns the database from the connection
      def db
        @db ||= client.database
      end

      # Returns a hash of all the rows from the database of a given collection
      def select_rows(collection)
        client[collection].find
      end

      def select_by_query(collection, query)
        client[collection].find(query)
      end

      # Inserts into the collection a given row or array of rows
      def insert_into(collection_name, row)
        if row.is_a?(Array)
          client[collection_name].insert_many(row)
        else
          client[collection_name].insert_one(row)
        end
      end

      # Updates a collection item with a given ID with the given attributes
      def update(collection_name, id, attributes)
        client[collection_name].replace_one({"_id" => id}, attributes)
      end

      # Upserts into the collection a given row
      def upsert(collection_name, row)
        # We can't use the save method of the Mongo collection
        # The reason is that it detects duplicates using _id
        # but we should detect it using pre_mongified_id instead
        # because in the case of sync, same rows are identified by their original sql ids

        if row.has_key?(:pre_mongified_id) || row.has_key?('pre_mongified_id')
          id = row[:pre_mongified_id] || row['pre_mongified_id']
          duplicate = find_one(collection_name, {"pre_mongified_id" => id})
          if duplicate
            update(collection_name, duplicate[:_id] || duplicate["_id"], row)
          else
            insert_into(collection_name, row)
          end
        else
          # no pre_mongified_id, use replace_one with upsert option
          if row[:_id] || row["_id"]
            id = row[:_id] || row["_id"]
            client[collection_name].replace_one({"_id" => id}, row, upsert: true)
          else
            insert_into(collection_name, row)
          end
        end
      end

      # Finds one item from a collection with the given query
      def find_one(collection_name, query)
        client[collection_name].find(query).first
      end

      # Returns a row of a item from a given collection with a given pre_mongified_id
      def get_id_using_pre_mongified_id(collection_name, pre_mongified_id)
        doc = client[collection_name].find('pre_mongified_id' => pre_mongified_id).first
        doc ? doc['_id'] : nil
      end

      # Removes pre_mongified_id from all records in a given collection
      def remove_pre_mongified_ids(collection_name)
        drop_mongified_index(collection_name)
        client[collection_name].update_many({}, { '$unset' => { 'pre_mongified_id' => 1} })
      end

      # Removes pre_mongified_id from collection
      # @param [String] collection_name name of collection to remove the index from
      # @return True if successful
      # @raise MongoDBError if index isn't found
      def drop_mongified_index(collection_name)
        index_names = client[collection_name].indexes.collect { |idx| idx['name'] }
        if index_names.include?("pre_mongified_id_1")
          client[collection_name].indexes.drop_one('pre_mongified_id_1')
        end
      end

      # Creates a pre_mongified_id index to ensure
      # speedy lookup for collections via the pre_mongified_id
      def create_pre_mongified_id_index(collection_name)
        client[collection_name].indexes.create_one({ 'pre_mongified_id' => 1 })
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
        client.database.drop
      end



    end
  end
end
