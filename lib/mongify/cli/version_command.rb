require File.join(File.dirname(File.dirname(File.dirname(File.expand_path(__FILE__)))), 'mongify')

module Mongify
  module CLI

    #
    # A command to report the application's current version number.
    #
    class VersionCommand
      def initialize(progname)
        @progname = progname
      end
      def execute(view)
        view.output("#{@progname} #{Mongify::VERSION}\n")
        view.report_success
      end
    end
  end
end
