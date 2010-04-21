require File.join(File.dirname(File.dirname(File.dirname(File.expand_path(__FILE__)))), 'core_ext', 'hash')
require File.join(File.dirname(File.dirname(File.dirname(File.expand_path(__FILE__)))), 'core_ext', 'array')

module Mongify
  module Database
    #
    # A column in the sql table
    #
    class Column
      
      attr_accessor :name
      attr_reader :options

      def initialize(*args)
        @options = args.extract_options!.stringify_keys
        self.name = args[0] unless args.empty?
        self
      end
      
    end
  end
end