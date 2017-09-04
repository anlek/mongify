module Mongify
  # The Command Line Interface module
  module CLI
    #
    # Represents an instance of a Mongify application.
    # This is the entry point for all invocations of Mongify from the
    # command line.
    #
    class Application

      # Successful execution exit code
      STATUS_SUCCESS = 0
      # Failed execution exit code
      STATUS_ERROR   = 1

      def initialize(arguments=[], stdin=$stdin, stdout=$stdout)
        arguments = ['-h'] if arguments.empty?
        @options = Options.new(arguments)
        @status = STATUS_SUCCESS
        Mongify::Configuration.in_stream = stdin
        Mongify::Configuration.out_stream = stdout
      end

      # Runs the application
      def execute!
        begin
          cmd = @options.parse
          return cmd.execute(self)
        rescue MongifyError => error
          $stderr.puts "Error: #{error}"
          report_error
        end
      end

      # Sends output to the UI
      def output(message)
        UI.puts(message)
      end

      # Sets status code as successful
      def report_success
        @status = STATUS_SUCCESS
      end

      # Sets status code as failure (or error)
      def report_error
        @status = STATUS_ERROR
      end
    end
  end
end
