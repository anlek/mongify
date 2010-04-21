require 'optparse'
require File.join(File.dirname(File.expand_path(__FILE__)), 'report')
#require File.join(File.dirname(File.expand_path(__FILE__)), 'translate_command')
require File.join(File.dirname(File.expand_path(__FILE__)), 'help_command')
require File.join(File.dirname(File.expand_path(__FILE__)), 'version_command')
module Mongify
  module CLI
    #
    # Used to parse the options for an application
    #
    class Options
      def initialize(argv)
        @argv = argv
        @parser = OptionParser.new
        @report_class = VerboseReport
        #@command_class = ReekCommand
        set_options
      end
      
      def banner
        progname = @parser.program_name
        return <<EOB
Usage: #{progname} [command] database.config [database_translation.rb]

Examples:

#{progname} check datbase.config
#{progname} process database.config database_translation.rb
#{progname} process -q database.config database_translation.rb

See http://github.com/anlek/mongify for more details

EOB
      end
      
      
      def set_options
        @parser.banner = banner
        @parser.separator "Common options:"
        @parser.on("-h", "--help", "Show this message") do
          @command_class = HelpCommand
        end
        @parser.on("-v", "--version", "Show version") do
          @command_class = VersionCommand
        end

        @parser.separator "\nReport formatting:"
        @parser.on("-q", "--[no-]quiet", "Suppress headings for smell-free source files") do |opt|
          @report_class = opt ? QuietReport : VerboseReport
        end
      end

      def parse
        @parser.parse!(@argv)
        
        if @command_class == HelpCommand
          HelpCommand.new(@parser)
        elsif @command_class == VersionCommand
          VersionCommand.new(@parser.program_name)
        else
          #TranslateCommand.create(sources, @report_class, @config_files)
        end
      end
      
      
    end
  end
end