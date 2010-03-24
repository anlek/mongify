require 'mongify/translation/sql_config'
require 'mongify/translation/mongodb_config'

module Mongify
  class Translation
    class << self
      def parse(file_name)
        translation = self.new.instance_eval(File.read(file_name))
      end
    end
    
    attr_reader :sql_config, :mongodb_config
    
    def initialize
      @tables = []
    end
    
    def table(*args)
      options = args.last.is_a?(Hash) ? args.pop : {}
      puts "table called with #{args.inspect} with options #{options.inspect}"
    end
    def sql_config(options=nil, &block)
      sql_config = SqlConfig.new(options)
      yield sql_config
      sql_config
    end
    def mongodb_config(options=nil, &block)
      mongodb_config = MongodbConfig.new(options)
      yield mongodb_config
      mongodb_config
    end
    
  end
end