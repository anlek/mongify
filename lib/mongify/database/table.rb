require 'mongify/database/column'

module Mongify
  module Database
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