require 'mongify/database'

module Mongify
  class Translation
    class << self
      def parse(file_name)
        translation = self.new
        translation.instance_eval(File.read(file_name))
        translation
      end
    end
    
    attr_reader :sql_config, :mongodb_config, :tables
    
    def initialize
      @tables = []
    end
    
    def table(table_name, options={}, &block)
      table = Mongify::Database::Table.new(table_name, options)
      #yield table if block
      @tables << table
    end
    def sql_config(options=nil, &block)
      @sql_config ||= Mongify::Database::SqlConfig.new(options) if options || block
      yield @sql_config if block
      @sql_config
    end
    def mongodb_config(options=nil, &block)
      @mongodb_config = Mongify::Database::MongodbConfig.new(options) if options || block
      yield @mongodb_config if block
      @mongodb_config
    end
    
  end
end