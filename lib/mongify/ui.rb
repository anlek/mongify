module Mongify
  #
  #  Used to output messages to the UI
  #
  class UI
    class << self
      # Outputs to stream using puts method
      def puts(msg)
        out_stream.puts(msg) if out_stream
      end

      # Outputs to stream using print method
      def print(msg)
        out_stream.print(msg) if out_stream
      end

      # Gets input from user
      def gets
        in_stream ? in_stream.gets : ''
      end

      # Outputs a question and gets input
      def request(msg)
        print(msg)
        gets.chomp
      end

      # Asks a yes or no question and waits for reply
      def ask(msg)
        request("#{msg} [yn] ") == 'y'
      end

      # Outputs a Warning (using puts command)
      def warn(msg)
        puts "WARNING: #{msg}"
      end

      # Outputs a message and aborts execution of app
      def abort(message)
        UI.puts "PROGRAM HALT: #{message}"
        Kernel.abort message
      end

      # Incoming stream
      def in_stream
        Configuration.in_stream
      end
      # Output stream
      def out_stream
        Configuration.out_stream
      end

      # Creates an instance of HighLine
      # which lets us figure out width of console
      # plus a whole lot more
      # @return [HighLine] instance
      def terminal_helper
        @terminal_helper ||= HighLine.new
      end
    end
  end
end