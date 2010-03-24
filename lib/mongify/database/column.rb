module Mongify
  class Database
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