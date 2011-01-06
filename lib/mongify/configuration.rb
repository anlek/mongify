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
    
    def mongodb_connection(options={}, &block)
      options.stringify_keys!
      options['adapter'] ||= 'mongodb'
      no_sql_connection(options, &block)
    end
    
    def sql_connection(options={}, &block)
      @sql_connection ||= Mongify::Database::SqlConnection.new(options)
      @sql_connection.instance_eval(&block) if block_given?
      @sql_connection
    end
    
    def no_sql_connection(options={}, &block)
      @no_sql_connection ||= Mongify::Database::NoSqlConnection.new(options)
      @no_sql_connection.instance_eval(&block) if block_given?
      @no_sql_connection
    end
    
  end
end