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
    
  end
end