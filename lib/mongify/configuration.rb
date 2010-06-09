require File.join(File.dirname(File.expand_path(__FILE__)), 'translation')
require File.join(File.dirname(File.expand_path(__FILE__)), 'exceptions')
require File.join(File.dirname(File.expand_path(__FILE__)), 'database', 'no_sql_config')
require File.join(File.dirname(File.expand_path(__FILE__)), 'database', 'sql_config')
module Mongify
  #
  #  This extracts the configuration for sql and no sql
  #
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
    
    def mongodb_config(options={}, &block)
      options.stringify_keys!
      options['adapter'] ||= 'mongodb'
      no_sql_config(options, &block)
    end
    
    def sql_config(options=nil, &block)
      @sql_config ||= Mongify::Database::SqlConfig.new(options) if options || block
      yield @sql_config if @sql_config && block
      @sql_config
    end
    
    def no_sql_config(options=nil, &block)
      @no_sql_config ||= Mongify::Database::NoSqlConfig.new(options) if options || block
      yield @no_sql_config if @no_sql_config && block
      @no_sql_config
    end
    
  end
end