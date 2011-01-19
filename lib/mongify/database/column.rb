require 'active_record/connection_adapters/abstract/schema_definitions'
module Mongify
  module Database
    #
    # A column in the sql table
    #
    class Column
      attr_reader :name, :type, :options
      
      AVAILABLE_OPTIONS = ['references', 'ignore']

      def initialize(name, type=:string, options={})
        @name = name
        type = :string if type.nil?
        @type = type.is_a?(Symbol) ? type : type.to_sym
        @options = options.stringify_keys
        
        auto_detect!
        
        self
      end
      
      def translate(value)
        return {} if ignored?
        case type
        when :key
          {"pre_mongified_id" => value}
        else
          {"#{name}" => type_cast(value)}
        end
      end
      
      def to_print
        "column \"#{name}\", :#{type}".tap do |output|
          output_options = options.map{|k, v| (v == nil) ? nil : ":#{k} => \"#{v}\""}.compact
          output << ", #{output_options.join(', ')}" unless output_options.blank?
        end
      end
      
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
      
      def reference?
        !self.options['references'].nil?
      end
      
      #######
      private
      #######
      
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
          when :date      then ActiveRecord::ConnectionAdapters::Column.string_to_date(value)
          when :binary    then ActiveRecord::ConnectionAdapters::Column.binary_to_string(value)
          when :boolean   then ActiveRecord::ConnectionAdapters::Column.value_to_boolean(value)
          else value
        end
      end
      
      def key?
        self.type == :key
      end
      
      def ignored?
        !!self.ignore
      end

      def auto_detect!
        case name.downcase
        when 'id'
          @type = :key if self.type == :integer
        when /(.*)_id/
          self.references = $1.to_s.pluralize unless self.references
        end
      end
      
      
    end
  end
end