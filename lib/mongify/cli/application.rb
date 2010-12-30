module Mongify
  module CLI
    #
    # Represents an instance of a Mongify application.
    # This is the entry point for all invocations of Mongify from the
    # command line.
    #
    class Application
      
      STATUS_SUCCESS = 0
      STATUS_ERROR   = 1
      
      def initialize(arguments=["--help"], stdin=$stdin, stdout=$stdout)
        @options = Options.new(arguments)
        @status = STATUS_SUCCESS
        Mongify::Configuration.in_stream = stdin
        Mongify::Configuration.out_stream = stdout
      end
      
      def execute!
        begin
          cmd = @options.parse
          cmd.execute(self)
        rescue Exception => error
          $stderr.puts "Error: #{error}"
          @status = STATUS_ERROR
        end
        return @status
      end
      
      def output(message)
        UI.puts(message)
      end
      
      def report_success
        @status = STATUS_SUCCESS
      end
    end
  end
end