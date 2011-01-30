require 'active_record/connection_adapters/abstract/schema_definitions'
module Mongify
  module Database
    #
    # A column that is used to access sql data and transform it into the no sql database
    #
    # 
    # ==== Structure
    # 
    # Structure for defining a column is as follows:
    #   column "name", :type, {options}
    # <em>Columns with no type given will be set to <tt>:string</tt></em>
    # 
    # ==== Notes
    # Leaving a column out when defining a table will result in a copy of the information (as a string).
    # ==== Types
    # 
    # Types of columns are supported:
    #   :key                  # Columns that are primary keys need to be marked as :key type
    #   :integer              # Will be converted to a integer
    #   :float                # Will be converted to a float
    #   :decimal              # Will be converted to a BigDecimal
    #   :string               # Will be converted to a string
    #   :text                 # Will be converted to a string
    #   :datetime             # Will be converted to a Time format (DateTime is not currently supported in the Mongo ruby driver)
    #   :date                 # Will be converted to a Time format (Date is not currently supported in the Mongo ruby driver)
    #   :timestamps           # Will be converted to a Time format
    #   :time                 # Will be converted to a Time format (the date portion of the Time object will be 2000-01-01)
    #   :binary               # Will be converted to a string
    #   :boolean              # Will be converted to a true or false values
    # 
    # ==== Options
    # 
    #   column "post_id", :integer, :referneces => :posts   # Referenced columns need to be marked as such, this will mean that they will be updated
    #                                                       # with the new BSON::ObjectID.
    # <b>NOTE: if you rename the table 'posts', you should set the :references to the new name</b>
    # 
    #   column "name", :string, :ignore => true             # Ignoring a column will make the column NOT copy over to the new database
    # 
    #   column "surname", :string, :rename_to => 'last_name'# Rename_to allows you to rename the column
    #
    #   column "post_id", :integer, :auto_detect => true    # Will run auto detect and make this column a :references => 'posts', :on => 'post_id' for you
    #                                                       # More used when reading a sql database, NOT recommended for use during processing of translation
    #   
    class Column
      attr_reader :sql_name, :type, :options
      
      #List of available options for a column
      AVAILABLE_OPTIONS = ['references', 'ignore', 'rename_to']
      
      # Auto detects if a column is an :key column or is a reference column
      def self.auto_detect(column)
        case column.sql_name.downcase
        when 'id'
          column.type = :key if column.type == :integer
        when /(.*)_id/
          column.references = $1.to_s.pluralize unless column.referenced? || column.type != :integer
        end
      end
      
      def initialize(sql_name, type=:string, options={})
        @sql_name = sql_name
        options, type = type, nil if type.is_a?(Hash)
        self.type = type
        @options = options.stringify_keys
        @auto_detect = @options.delete('auto_detect')
        run_auto_detect!
        
        self
      end
      
      # Allows you to set a type
      def type=(value=:string)
        value = :string if value.nil?
        @type = value.is_a?(Symbol) ? value : value.to_sym
      end
      
      # Returns the no_sql record name
      def name
        @name ||= rename_to || sql_name
      end
      
      # Returns a translated hash from a given value
      # Example:
      #   @column = Column.new("surname", :string, :rename_to => 'last_name')
      #   @column.translate("Smith") # => {"last_name" => "Smith"}
      def translate(value)
        return {} if ignored?
        case type
        when :key
          {"pre_mongified_id" => value}
        else
          {"#{name}" => type_cast(value)}
        end
      end
      
      # Returns a string representation of the column as it would show in a translation file.
      # Mainly used during print out of translation file
      def to_print
        "column \"#{name}\", :#{type}".tap do |output|
          output_options = options.map{|k, v| (v == nil) ? nil : ":#{k} => \"#{v}\""}.compact
          output << ", #{output_options.join(', ')}" unless output_options.blank?
        end
      end
      alias :to_s :to_print
      
      # Sets up a accessor method for an option
      #
      #   def rename_to=(value)
      #     options['rename_to'] = value
      #   end
      #   def rename_to
      #     options['rename_to']
      #   end
      def method_missing(meth, *args, &blk)
        method_name = meth.to_s.gsub("=", '')
        if AVAILABLE_OPTIONS.include?(method_name)
          class_eval <<-EOF
                          def #{method_name}=(value)
                            options['#{method_name}'] = value
                          end
                          def #{method_name}
                            options['#{method_name}']
                          end
                        EOF
          send(meth, *args, &blk)
        else
          super(meth, *args, &blk)
        end
      end
      
      # Returns true if the column is a reference column
      def referenced?
        !self.options['references'].nil?
      end
      
      # Returns true if column is being renamed
      def renamed?
        self.name != self.sql_name
      end
      
      # Returns true if column is a :key type column
      def key?
        self.type == :key
      end
      
      # Returns true if column should be auto_detected (passed via options)
      def auto_detect?
        !!@auto_detect
      end
      
      # Returns true if column is ignored
      def ignored?
        !!self.ignore
      end
      
      #######
      private
      #######
      
      # Casts the value to a given type
      def type_cast(value)
        return nil if value.nil?
        case type
          when :string    then value
          when :text      then value
          when :integer   then value.to_i rescue value ? 1 : 0
          when :float     then value.to_f
          when :decimal   then ActiveRecord::ConnectionAdapters::Column.value_to_decimal(value)
          when :datetime  then ActiveRecord::ConnectionAdapters::Column.string_to_time(value)
          when :timestamp then ActiveRecord::ConnectionAdapters::Column.string_to_time(value)
          when :time      then ActiveRecord::ConnectionAdapters::Column.string_to_dummy_time(value)
          when :date      then ActiveRecord::ConnectionAdapters::Column.string_to_time(value)
          when :binary    then ActiveRecord::ConnectionAdapters::Column.binary_to_string(value)
          when :boolean   then ActiveRecord::ConnectionAdapters::Column.value_to_boolean(value)
          else value
        end
      end
      

      # runs auto detect (see {Mongify::Database::Column.auto_detect})
      def run_auto_detect!
        self.class.auto_detect(self) if auto_detect?
      end
      
      
    end
  end
end