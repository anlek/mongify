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
    #   :key                  # Columns that are primary keys need to be marked as :key type. You can provide an :as if your :key is not an integer column
    #   :integer              # Will be converted to a integer
    #   :float                # Will be converted to a float
    #   :decimal              # Will be converted to a string *(you can change default behaviour read below)
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
    #   column "post_id", :integer, :references => :posts   # Referenced columns need to be marked as such, this will mean that they will be updated
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
    # <em>For decimal columns you can specify a few options:</em>
    #   column "total",                                     # This is a default conversion setting.
    #          :decimal,
    #          :as => 'string'
    #
    #   column "total",                                     # You can specify to convert your decimal to integer
    #           :decimal,                                   # specifying scale will define how many decimal places to keep
    #           :as => 'integer',                           # Example: :scale => 2 will convert 123.4567 to 12346 in to mongodb
    #           :scale => 2
    # ==== Decimal Storage
    #
    # Unfortunately MongoDB Ruby Drivers doesn't support BigDecimal, so to ensure all data is stored correctly (without losing information)
    # I've chosen to store as String, however you can overwrite this functionality in one of two ways:
    # <em>The reason you would want to do this, is to make this searchable via a query.</em>
    #
    # <b>1) You can specify :as => 'integer', :scale => 2</b>
    #   column "total", :decimal, :as => 'integer', :scale => 2
    #
    #   #It would take a value of 123.456 and store it as an integer of value 12346
    #
    # <b>2) You can specify your own custom conversion by doing a {Mongify::Database::Table#before_save}
    #
    # Example:
    #   table "invoice" do
    #     column "name", :string
    #     column "total", :decimal
    #     before_save do |row|
    #       row.total = (BigDecimal.new(row.total) * 1000).round
    #     end
    #   end
    #
    # This would take 123.456789 in the total column and convert it to an interger of value 123457 (and in your app you can convert it back to a decimal)
    #
    # *REMEMBER* there is a limit on how big of an integer you can store in BSON/MongoDB (http://bsonspec.org/#/specification)
    class Column
      attr_reader :sql_name, :type, :options

      #List of available options for a column
      AVAILABLE_OPTIONS = ['references', 'ignore', 'rename_to', 'as', 'scale']

      # Auto detects if a column is an :key column or is a reference column
      def self.auto_detect(column)
        case column.sql_name.downcase
        when 'id'
          column.as = column.type
          column.type = :key
        when /(.*)_id/
          column.references = $1.to_s.pluralize unless column.referenced?
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
            {"pre_mongified_id" => type_cast(value)}
          else
            {"#{self.name}" => type_cast(value)}
        end
      end

      # Returns a string representation of the column as it would show in a translation file.
      # Mainly used during print out of translation file
      def to_print
        "column \"#{sql_name}\", :#{type}".tap do |output|
          output_options = options.map do |k, v|
            next if v.nil?
            ":#{k} => #{v.is_a?(Symbol) ? ":#{v}" : %Q["#{v}"] }"
          end.compact
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
          unless self.class.method_defined?(method_name.to_sym)
            class_eval <<-EOF
                            def #{method_name}=(value)
                              options['#{method_name}'] = value
                            end
                          EOF
          end
          unless self.class.method_defined?("#{method_name}=".to_sym)
            class_eval <<-EOF
                            def #{method_name}
                              options['#{method_name}']
                            end
                          EOF
          end
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

      # Used when trying to figure out how to convert a decimal value
      # @return [String] passed option['as'] or defaults to 'string'
      def as
        options['as'] ||= :string
      end
      # Sets option['as'] to either 'string' or 'integer', defults to 'string' for unknown values
      # @param [String|Symbol] value, can be either 'string' or 'integer
      def as=(value)
        value = value.to_s.downcase.to_sym
        options['as'] = [:string, :integer].include?(value) ? value : :string
      end
      # Returns true if :as was passed as integer
      def as_integer?
        self.as == :integer
      end

      # Get the scale option for decimal to integer conversion
      #   column 'total', :decimal, :as => 'integer', :scale => 3
      # @return [integer] passed option['scale'] or 0
      def scale
        options['scale'] ||= 0
      end
      # Set the scale option for decimal to integer conversion
      #   column 'total', :decimal, :as => 'integer', :scale => 3
      # @param [Integer] number of decimal places to round off to
      def scale=(value)
        options['scale'] = value.to_i
      end

      # Casts the value to a given type
      def type_cast(value)
        return nil if value.nil?
        case type
          when :key       then options['as'] == :string ? value.to_s : value.to_i #If :as is provided, check if it's string, otherwise integer
          when :string    then value.to_s
          when :text      then value.to_s
          when :integer   then value.to_i
          when :float     then value.to_f
          when :decimal
            value = ActiveRecord::Type::Decimal.new.type_cast_from_database(value)
            if as_integer?
              (value * (10 ** self.scale)).round.to_i
            else
              value.to_s
            end
          when :datetime  then ActiveRecord::Type::DateTime.new.type_cast_from_database(value)
          when :timestamp then ActiveRecord::Type::DateTime.new.type_cast_from_database(value)
          when :time      then ActiveRecord::Type::Time.new.type_cast_from_database(value)
          when :date      then ActiveRecord::Type::DateTime.new.type_cast_from_database(value)
          when :binary    then ActiveRecord::Type::Binary.new.type_cast_from_database(value)
          when :boolean   then ActiveRecord::Type::Boolean.new.type_cast_from_database(value)
          else value.to_s
        end
      end

      #######
      private
      #######

      # runs auto detect (see {Mongify::Database::Column.auto_detect})
      def run_auto_detect!
        self.class.auto_detect(self) if auto_detect?
      end
    end
  end
end