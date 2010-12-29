require 'mongify/translation/generator'
module Mongify
  #
  # Actually runs the translation from sql to no sql
  #
  class Translation
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
    def sql_config(options=nil, &block)
      UI.warn("sql_config should be placed in your configuration file")
    end
    def mongodb_config(options=nil, &block)
      UI.warn("mongodb_config should be placed in your configuration file")
    end
    
  end
end