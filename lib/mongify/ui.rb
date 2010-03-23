module Mongify
  class UI
    class << self
      def puts(msg)
        Configuration.out_stream.puts(msg) if Configuration.out_stream
      end
    
      def print(msg)
        Configuration.out_stream.print(msg) if Configuration.out_stream
      end
    
      def gets
        Configuration.in_stream ? Configuration.in_stream.gets : ''
      end
    
      def request(msg)
        print(msg)
        gets.chomp
      end
    
      def ask(msg)
        request("#{msg} [yn] ") == 'y'
      end
      
      def abort(message='')
        UI.puts message
        Kernel.abort
      end
    end
  end
end