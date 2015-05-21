module Mongify
  module CLI
    module Command
      #
      # A command to display usage information for this application.
      #
      class Help
        def initialize(parser)
          @parser = parser
        end
        #Executes the help command
        def execute(view)
          view.output(@parser.to_s)
          view.report_success
        end
      end
    end
  end
end