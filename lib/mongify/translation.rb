require 'mongify/translation/printer'
module Mongify
  #
  # Actually runs the translation from sql to no sql
  #
  class Translation
    include Mongify::Translation::Printer
    class << self
      def parse(file_name)
        translation = self.new
        translation.instance_eval(File.read(file_name))
        translation
      end
      
      def load(connection)
        raise Mongify::SqlConnectionRequired, "Can only read from Mongify::Database::SqlConnection" unless connection.is_a?(Mongify::Database::SqlConnection)
        return unless connection.has_connection?
        translation = self.new
        connection.tables.each do |t|
          columns = []
          connection.columns_for(t).each do |ar_col|
            columns << Mongify::Database::Column.new(ar_col.name, ar_col.type, :default => ar_col.default)
          end
          translation.table(t, :columns => columns)
        end
        translation
      end
    end
    
    attr_reader :tables
    
    def initialize
      @tables = []
    end
    
    def table(table_name, options={}, &block)
      table = Mongify::Database::Table.new(table_name, options)
      #yield table if block
      @tables << table
    end
    
    def add_table(table)
      @tables << table
    end
    
    #######
    private
    #######

    
    
  end
end