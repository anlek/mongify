require 'mongify/translation/printer'
require 'mongify/translation/process'
module Mongify
  #
  # Actually runs the translation from sql to no sql
  #
  class Translation
    include Printer
    include Process
    class << self
      def parse(file_name)
        translation = self.new
        translation.instance_eval(File.read(file_name))
        translation
      end
      
      def load(connection)
        raise Mongify::SqlConnectionRequired, "Can only read from Mongify::Database::SqlConnection" unless connection.is_a?(Mongify::Database::SqlConnection)
        return unless connection.valid? && connection.has_connection?
        translation = self.new
        connection.tables.each do |t|
          columns = []
          connection.columns_for(t).each do |ar_col|
            columns << Mongify::Database::Column.new(ar_col.name, ar_col.type)
          end
          translation.table(t, :columns => columns)
        end
        translation
      end
    end
    
    def initialize
      @all_tables = []
    end
    
    def table(table_name, options={}, &block)
      table = Mongify::Database::Table.new(table_name, options, &block)
      @all_tables << table
    end
    
    def add_table(table)
      @all_tables << table
    end
    
    def all_tables
      @all_tables
    end
    
    def tables
      all_tables.reject{ |t| t.ignored? }
    end
    
    def copy_tables
      tables.reject{|t| t.embed?}
    end
    
    def embed_tables
      tables.reject{|t| !t.embed?}
    end
    
  end
end
