module Mongify
  module Database
    #
    #  A representation of a sql table and how it should map to a no_sql system 
    #
    class Table
      
      attr_accessor :name
      attr_reader :options, :columns
      
      def initialize(name, options={}, &block)
        @columns = []
        @column_lookup = {}
        @options = options.stringify_keys
        self.name = name
        
        self.instance_exec(&block) if block_given?
        
        import_columns
        
        self
      end
      
      #Add a Database Column
      def add_column(column)
        raise Mongify::DatabaseColumnExpected, "Expected a Mongify::Database::Column" unless column.is_a?(Mongify::Database::Column)
        add_column_index(column.name, @columns.size)
        @columns << column
      end
      
      
      def column(name, type=nil, options={})
        options = type and type = nil if type.is_a?(Hash)
        type = type.to_sym if type
        add_column_index(name.to_s.downcase, @columns.size)
        @columns << (col = Mongify::Database::Column.new(name, type, options))
        col
      end
      
      def find_column(name)
        return nil unless (index = @column_lookup[name.to_s.downcase])
        @columns[index]
      end
      
      
      def reference_columns
        @columns.reject{ |c| !c.reference? } 
      end
      
      def translate(row)
        new_row = {}
        row.each do |key, value|
          c = find_column(key)
          new_row.merge!(c.present? ? c.translate(value) : {"#{key}" => value})
        end
        new_row
      end
      
      def embed_in
        @options['embed_in'].to_s unless @options['embed_in'].nil?
      end
      
      def embed_as
        return nil unless embed?
        return 'object' if @options['as'].to_s.downcase == 'object'
        'array'
      end
      
      def embed_as_object?
        embed_as == 'object'
      end
      
      def embed?
        embed_in.present?
      end
      
      def embed_on
        return nil unless embed?
        (@options['on'] || "#{@options['embed_in'].to_s.singularize}_id").to_s
      end
            
      #######
      private
      #######
      
      def add_column_index(name, index)
        @column_lookup[name] = index
      end

      def import_columns
        return unless import_columns = @options.delete('columns')
        import_columns.each { |c| add_column(c) }
      end
      
    end
  end
end