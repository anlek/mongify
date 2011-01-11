require 'optparse'
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

Commands:
#{Mongify::CLI::WorkerCommand.list_commands.join("\n")}

Examples:

#{progname} translate -c datbase.config
#{progname} t -c database.config
#{progname} process -c database.config database_translation.rb

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
        @parser.on('-c', '--config FILE', "Configuration File to use") do |file|
          @config_file = file
        end

        @parser.separator "\nReport formatting:"
        @parser.on("-q", "--[no-]quiet", "Suppress extra output") do |opt|
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
          raise ConfigurationFileNotFound unless @config_file
          #TODO: In the future, request sql_connection and nosql_connection from user input
          config = Configuration.parse(@config_file)
          
          WorkerCommand.new(@argv[0], config, translation_file, @parser)
        end
      end
      
      private
      
      def translation_file(argv=@argv)
        return nil if argv.length < 2
        argv[1]
      end
      
      def action(argv=@argv)
        @argv.try(:[],0) || ''
      end
            
      
    end
  end
end