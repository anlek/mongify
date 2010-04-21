require File.join(File.dirname(File.expand_path(__FILE__)), 'configuration')
module Mongify
  #
  #  Used to output messages to the UI
  #
  class UI
    class << self
      def puts(msg)
        out_stream.puts(msg) if out_stream
      end
    
      def print(msg)
        out_stream.print(msg) if out_stream
      end
    
      def gets
        in_stream ? in_stream.gets : ''
      end
    
      def request(msg)
        print(msg)
        gets.chomp
      end
    
      def ask(msg)
        request("#{msg} [yn] ") == 'y'
      end
      
      def warn(msg)
        puts "WARNING: #{msg}"
      end
      
      def abort(message)
        UI.puts message
        abort
      end
      
      def in_stream
        Configuration.in_stream
      end
      def out_stream
        Configuration.out_stream
      end
    end
  end
end