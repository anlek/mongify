module Mongify
  class UI
    class << self
      def puts(msg)
        Config.out_stream.puts(msg) if Config.out_stream
      end
    
      def print(msg)
        Config.out_stream.print(msg) if Config.out_stream
      end
    
      def gets
        Config.in_stream ? Config.in_stream.gets : ''
      end
    
      def request(msg)
        print(msg)
        gets.chomp
      end
    
      def ask(msg)
        request("#{msg} [yn] ") == 'y'
      end
    end
  end
end