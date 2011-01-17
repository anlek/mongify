require 'optparse'
module Mongify
  module CLI
    #
    # Used to parse the options for an application
    #
    class Options
      def initialize(argv)
        @parsed = false
        @argv = argv
        @parser = OptionParser.new
        @report_class = VerboseReport
        #@command_class = ReekCommand
        set_options
        
      end
      
      def banner
        progname = @parser.program_name
        return <<EOB
Usage: #{progname} command [database_translation.rb] [-c database.config]

Commands:
#{Mongify::CLI::WorkerCommand.list_commands.join("\n")}

Examples:

#{progname} translate -c datbase.config
#{progname} tr -c database.config
#{progname} check -c database.config
#{progname} process database_translation.rb -c database.config

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
        parse_options
        
        if @command_class == HelpCommand
          HelpCommand.new(@parser)
        elsif @command_class == VersionCommand
          VersionCommand.new(@parser.program_name)
        else
          raise ConfigurationFileNotFound, "You need to provide a configuration file location #{@config_file}" unless @config_file
          #TODO: In the future, request sql_connection and nosql_connection from user input
          config = Configuration.parse(@config_file)
          
          WorkerCommand.new(action, config, translation_file, @parser)
        end
      end
      
      private
      
      def translation_file(argv=@argv)
        parse_options
        return nil if argv.length < 2
        argv[1]
      end
      
      def action(argv=@argv)
        parse_options
        @argv.try(:[],0) || ''
      end
            
      def parse_options
        @parsed = true && @parser.parse!(@argv) unless @parsed
      end      
      
      
    end
  end
end