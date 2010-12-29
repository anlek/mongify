module Mongify
  module Database
    #
    #  A representation of a sql table and how it should map to a no_sql system 
    #
    class Table
      
      attr_accessor :name
      attr_reader :options, :columns
      
      def initialize(name, *args)
        @columns = []
        @options = args.extract_options!.stringify_keys
        self.name = name
        
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
        @columns.find{ |col| col.name == name }
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