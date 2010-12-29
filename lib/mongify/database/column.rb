module Mongify
  module Database
    #
    # A column in the sql table
    #
    class Column
      attr_reader :name, :type, :options

      def initialize(name, type=:string, *args)
        @name = name
        @type = type
        @options = args.extract_options!.stringify_keys
        
        self
      end
      
    end
  end
end