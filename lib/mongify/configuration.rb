module Mongify
  class Configuration
    class << self
      attr_accessor :in_stream, :out_stream
      
      def parse_file(file_name)
        raise "File #{file_name} is missing" unless File.exists?(file_name)
        Mongify::Translation.parse(file_name)
      end
      
    end
    
    def initialize
      
    end
    
    
  end
end