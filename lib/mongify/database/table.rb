require File.join(File.dirname(File.expand_path(__FILE__)), 'column')

module Mongify
  module Database
    #
    #  A representation of a sql table and how it should map to a no_sql system 
    #
    class Table
      
      attr_accessor :name
      attr_reader :options, :columns
      
      def initialize(*args)
        @columns = []
        @options = args.extract_options!.stringify_keys
        self.name = args[0] unless args.empty?
        self
      end
      
      def column(name, options={})
        @columns << Mongify::Database::Column.new(name, options)
      end
      
      def find_column(name)
        @columns.find{ |c| c.name == name }
      end

    end
  end
end