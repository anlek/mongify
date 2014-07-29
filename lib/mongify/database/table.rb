module Mongify
  module Database
    #
    #  A representation of a sql table and how it should map to a no_sql collection
    #
    # ==== Structure
    #
    # Structure for defining a table is as follows:
    #   table "table_name", {options} do
    #     # columns go here...
    #   end
    #
    # ==== Options
    #
    # Table Options are as follow:
    #   table "table_name"                                        # Does a straight copy of the table
    #   table "table_name", :embed_in => 'users'                  # Embeds table_name into users, assuming a user_id is present in table_name.
    #                                                             # This will also assume you want the table embedded as an array.
    #
    #   table "table_name",                                       # Embeds table_name into users, linking it via a owner_id
    #         :embed_in => 'users',                               # This will also assume you want the table embedded as an array.
    #         :on => 'owner_id'
    #
    #   table "table_name",                                       # Embeds table_name into users as a one to one relationship
    #         :embed_in => 'users',                               # This also assumes you have a user_id present in table_name
    #         :on => 'owner_id',                                  # You can also specify both :on and :as options when embedding
    #         :as => 'object'                                     # NOTE: If you rename the owner_id column, make sure you
    #                                                             # update the :on to the new column name
    #
    #
    #   table "table_name", :rename_to => 'my_table'              # This will allow you to rename the table as it's getting process
    #                                                             # Just remember that columns that use :reference need to
    #                                                             # reference the new name.
    #
    #   table "table_name", :ignore => true                       # This will ignore the whole table (like it doesn't exist)
    #                                                             # This option is good for tables like: schema_migrations
    #
    #   table "table_name",                                       # This allows you to specify the table as being polymorphic
    #         :polymorphic => 'notable',                          # and provide the name of the polymorphic relationship.
    #         :embed_in => true                                   # Setting embed_in => true allows the relationship to be
    #                                                             # embedded directly into the parent class.
    #                                                             # If you do not embed it, the polymorphic table will be copied in to
    #                                                             # MongoDB and the notable_id will be updated to the new BSON::ObjectID
    #
    #   table "table_name" do                                     # A table can take a before_save block that will be called just
    #     before_save do |row|                                    # before the row is saved to the no sql database.
    #       row.admin = row.delete('permission').to_i > 50        # This gives you the ability to do very powerful things like:
    #     end                                                     # Moving records around, renaming records, changing values in row based on
    #   end                                                       # some values! Checkout Mongify::Database::DataRow to learn more
    #
    #
    #   table "preferences", :embed_in => "users" do               # As of version 0.2, embedded tables with a before_save will take an
    #     before_save do |pref_row, user_row|                      # extra argument which is the parent row of the embedded table.
    #       user_row.email_me = pref_row.delete('email_me')        # This gives you the ability to move things from an embedded table row
    #     end                                                      # to the parent row.
    #   end
    #

    class Table

      attr_accessor :name, :sql_name
      attr_reader :options, :columns

      def initialize(sql_name, options={}, &block)
        @columns = []
        @column_lookup = {}
        @options = options.stringify_keys
        self.sql_name = sql_name

        self.instance_exec(&block) if block_given?

        import_columns

        self
      end

      # Returns the no_sql collection name
      def name
        @name = @options['rename_to'] || @name || self.sql_name
      end

      # Returns true if table is ignored
      def ignored?
        @options['ignore']
      end

      # Returns true if table is marked as polymorphic
      def polymorphic?
        !!@options['polymorphic']
      end

      # Returns the name of the polymorphic association
      def polymorphic_as
        @options['polymorphic'].to_s
      end

      # Add a Database Column to the table
      # This expects to get a {Mongify::Database::Column} or it will raise {Mongify::DatabaseColumnExpected} otherwise
      def add_column(column)
        raise Mongify::DatabaseColumnExpected, "Expected a Mongify::Database::Column" unless column.is_a?(Mongify::Database::Column)
        add_and_index_column(column)
      end

      # Lets you build a column in the table
      def column(name, type=nil, options={})
        options, type = type, nil if type.is_a?(Hash)
        type = type.to_sym if type
        add_and_index_column(Mongify::Database::Column.new(name, type, options))
      end

      # Returns the column if found by the sql_name
      def find_column(name)
        return nil unless (index = @column_lookup[name.to_s.downcase.to_sym])
        @columns[index]
      end

      # Returns a array of Columns which reference other columns
      def reference_columns
        @columns.reject{ |c| !c.referenced? }
      end

      # Returns the column of type :key
      def key_column
        @columns.find{ |c| c.type == :key }
      end

      # Returns a translated row
      # Takes in a hash of values
      def translate(row, parent=nil)
        new_row = {}
        row.each do |key, value|
          c = find_column(key)
          new_row.merge!(c.translate(value)) if c.present?
        end
        run_before_save(new_row, parent)
      end


      # Returns the name of the embed_in collection
      def embed_in
        @options['embed_in'].to_s unless @options['embed_in'].nil?
      end

      # Returns the type of embed it will be [object or array]
      def embed_as
        return nil unless embedded?
        return 'object' if @options['as'].to_s.downcase == 'object'
        'array'
      end

      # Returns true if table is being embed as an object
      def embedded_as_object?
        embed_as == 'object'
      end

      # Returns true if this is an embedded table
      def embedded?
        embed_in.present?
      end

      # Returns the name of the target column to embed on
      def embed_on
        return nil unless embedded?
        (@options['on'] || "#{@options['embed_in'].to_s.singularize}_id").to_s
      end

      # Used to save a block to be ran after the row has been processed but before it's saved to the no sql database
      def before_save(&block)
        @before_save_callback = block
      end

      #Used to remove any before save filter
      def remove_before_save_filter!
        @before_save_callback = nil
      end

      #######
      private
      #######

      # Runs the before save
      # Returns: a new modified row
      def run_before_save(row, parent=nil)
        parentrow = Mongify::Database::DataRow.new(parent) unless parent.nil?
        datarow = Mongify::Database::DataRow.new(row)

        # don't allow deletion of pre_mongified_id, sync needs it!
        pre_mongified_id = row['pre_mongified_id']
        @before_save_callback.call(datarow, parentrow) unless @before_save_callback.nil?
        new_row = datarow.to_hash
        new_row['pre_mongified_id'] = pre_mongified_id if pre_mongified_id

        if parentrow
          parentrow_hash = parentrow.to_hash
          unsets = parent.keys.inject({}) do |unset_keys, key|
            unset_keys[key] = '1' unless parentrow_hash.has_key?(key)
            unset_keys
          end
          [new_row, parentrow_hash, unsets]
        else
          new_row
        end
      end

      # Indexes the column on the sql_name and adds column to the array
      def add_and_index_column(column)
        @column_lookup[column.sql_name.downcase.to_sym] = @columns.size
        @columns << column
        column
      end

      # Imports colunms that are sent in via the options['columns']
      def import_columns
        return unless import_columns = @options.delete('columns')
        import_columns.each { |c| add_column(c) }
      end

    end
  end
end