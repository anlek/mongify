module Mongify
  module Database
    class Reader
      attr_reader :connection, :translation
      def initialize(connection)
        raise Mongify::SqlConnectionRequired, "Can only read from Mongify::Database::SqlConnection" unless connection.is_a?(Mongify::Database::SqlConnection)
        self.connection = connection
      end
      
      def connection=(value)
        reset
        @connection=value
        @connection.has_connection?
        @connection
      end
      
      def print
        ''.tap do |output|
          translation.tables.each do |t|
            output << %Q[table "#{t.name}" do\n]
              t.columns.each do |c|
                output << %Q[\tcolumn "#{c.name}", :#{c.type}#{ ", :default => #{c.options[:default]}" if c.options[:default]}\n]
              end
            output << "end\n\n"
          end
        end
      end
      
      def translation
        return @translation if @translation
        @translation = Mongify::Translation.new
        connection.tables.each do |t|
          columns = []
          connection.columns_for(t).each do |ar_col|
            columns << Mongify::Database::Column.new(ar_col.name, ar_col.type, :default => ar_col.default)
          end
          @translation.table(t, :columns => columns)
        end
        @translation
      end
      
      def reset
        @translation = nil
      end
      
      #######
      private
      #######

      

    end #Reader
  end
end
