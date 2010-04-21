require File.join(File.dirname(File.expand_path(__FILE__)), 'translation')
require File.join(File.dirname(File.expand_path(__FILE__)), 'exceptions')
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

    end #self
    
    
    def sql_config(options=nil, &block)
      @sql_config ||= Mongify::Database::SqlConfig.new(options) if options || block
      yield @sql_config if block
      @sql_config
    end
    
    def mongodb_config(options=nil, &block)
      no_sql_config(options, &block)
    end
    
    def no_sql_config(options=nil, &block)
      @no_sql_config ||= Mongify::Database::NoSqlConfig.new(options) if options || block
      yield @no_sql_config if block
      @no_sql_config
    end
    
  end
end