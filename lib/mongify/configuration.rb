module Mongify
  #
  # Handles all tasks regarding the connection to sql and no-sql database
  # It also handles the parsing of the data
  #
  class Configuration
    class << self
      attr_accessor :in_stream, :out_stream

      # Parses a external configuration file and evaluates it and returns a instence of a configuration class
      def parse(file_name)
        raise Mongify::ConfigurationFileNotFound, "File #{file_name} is missing" unless File.exists?(file_name)
        config = self.new
        config.instance_eval(File.read(file_name))
        config
      end

    end #self

    # Returns a no_sql_connection which is bound to a mongodb adapter
    # or builds a new no_sql_connection if block is given
    def mongodb_connection(options={}, &block)
      return @mongodb_conncetion if @mongodb_connection and !block_given?
      options.stringify_keys!
      options['adapter'] ||= 'mongodb'
      @mongodb_connection = no_sql_connection(options, &block)
    end

    # Returns a sql_connection
    # If a block is given, it will be executed on the connection
    # For more information, see {Mongify::Database::SqlConnection}
    def sql_connection(options={}, &block)
      @sql_connection ||= Mongify::Database::SqlConnection.new(options)
      @sql_connection.instance_exec(&block) if block_given?
      @sql_connection
    end

    # Returns a sql_connection
    # If a block is given, it will be executed on the connection
    # For more information, see {Mongify::Database::NoSqlConnection}
    def no_sql_connection(options={}, &block)
      @no_sql_connection ||= Mongify::Database::NoSqlConnection.new(options)
      @no_sql_connection.instance_exec(&block) if block_given?
      @no_sql_connection
    end

  end
end