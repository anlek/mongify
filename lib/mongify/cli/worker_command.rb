module Mongify
  module CLI

    #
    # A command to run the different commands in the application (related to Mongifying).
    #
    class WorkerCommand
      attr_accessor :view
      def initialize(command, config=nil, translation=nil)
        @command = command.to_s.downcase
        @config = config
        @translatipon = translation
      end
      
      def execute(view)
        self.view = view
        case @command
        when 't', 'translation'
          check_configuration
          view.output(Mongify::Translation.load(@config.sql_connection).print)
        else
          view.output("Unknown action #{@command}")
          view.report_error
          return
        end
        view.report_success
      end
      
      #######
      private
      #######

      def check_configuration(sql_only = false)
        @config.sql_connection.valid? && @config.sql_connection.has_connection?
      end
      
      
    end
  end
end
