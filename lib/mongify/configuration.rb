module Mongify
  class Configuration
    class << self
      attr_accessor :in_stream, :out_stream
      
      def parse_translation(file_name)
        raise Mongify::FileNotFound, "File #{file_name} is missing" unless File.exists?(file_name)
        Mongify::Translation.parse(file_name)
      end
      
      def parse_configuration(file_name)
        raise Mongify::FileNotFound, "File #{file_name} is missing" unless File.exists?(file_name)
        Mongify::Configuration.parse(file_name)
      end
      
      def parse(file_name)
        config = self.new
        config.instance_eval(File.read(file_name))
        config
      end
      
    end
    
    attr_reader :sql_config, :nosql_config
    
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