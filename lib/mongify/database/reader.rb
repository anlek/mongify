module Mongify
  module Database
    class Reader
      attr_reader :connection, :translation
      def initialize(connection)
        raise Mongify::SqlConnectionRequired, "Can only read from Mongify::Database::SqlConnection" unless connection.is_a?(Mongify::Database::SqlConnection)
        self.connection = connection
      end
      
      def connection=(value)
        @translation = nil
        @connection=value
      end
      
      def read
        if connection.has_connection?
          @translation = Mongify::Translation.new
          connection.tables.each do |t|
            columns = []
            connection.columns_for(t).each do |ar_col|
              columns << Mongify::Database::Column.new(ar_col.name, ar_col.type, :default => ar_col.default)
            end
            @translation.table(t, :columns => columns)
          end
          return @translation
        end
      end
    end
  end
end
