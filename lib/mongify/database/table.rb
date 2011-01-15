module Mongify
  module Database
    #
    #  A representation of a sql table and how it should map to a no_sql system 
    #
    class Table
      
      attr_accessor :name
      attr_reader :options, :columns
      
      def initialize(name, *args, &block)
        @columns = []
        @options = args.extract_options!.stringify_keys
        self.name = name
        
        self.instance_exec(&block) if block_given?
        
        import_columns
        
        self
      end
      
      #Add a Database Column
      def add_column(column)
        raise Mongify::DatabaseColumnExpected, "Expected a Mongify::Database::Column" unless column.is_a?(Mongify::Database::Column)
        @columns << column
      end
      
      
      def column(name, type=nil, options={})
        options = type and type = nil if type.is_a?(Hash)
        type = type.to_sym if type
        @columns << (col = Mongify::Database::Column.new(name, type, options))
        col
      end
      
      def find_column(name)
        #OPTIMIZE: Possible to add hash with column name, pointing to the index of the @columns array
        self.columns.find{ |col| col.name.downcase == name.downcase }
      end
      
      def translate(row)
        new_row = {}
        row.each do |key, value|
          c = find_column(key)
          new_row.merge!(c.present? ? c.translate(value) : {"#{key}" => value})
        end
        new_row
      end
            
      #######
      private
      #######

      def import_columns
        return unless import_columns = @options.delete('columns')
        import_columns.each { |c| add_column(c) }
      end
      
    end
  end
end