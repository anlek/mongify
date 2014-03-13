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
        #@command_class = ReekCommand
        set_options
        parse_options
      end

      # Banner for help output
      def banner
        progname = @parser.program_name
        return <<EOB
Usage: #{progname} command database.config [database_translation.rb]

Commands:
#{Mongify::CLI::Command::Worker.list_commands.join("\n")}

Examples:

#{progname} check database.config
#{progname} translation datbase.config > database_translation.rb
#{progname} process database.config database_translation.rb
#{progname} sync database.config database_translation.rb

See http://github.com/anlek/mongify for more details

EOB
      end

      # Sets the options for CLI
      # Also used for help output
      def set_options
        @parser.banner = banner
        @parser.separator "Common options:"
        @parser.on("-h", "--help", "Show this message") do
          @command_class = Command::Help
        end
        @parser.on("-v", "--version", "Show version") do
          @command_class = Command::Version
        end
      end

      # Parses CLI passed attributes and figures out what command user is trying to run
      def parse
        if @command_class == Command::Help
          Command::Help.new(@parser)
        elsif @command_class == Command::Version
          Command::Version.new(@parser.program_name)
        else
          Command::Worker.new(action, config_file, translation_file, @parser)
        end
      end

      #######
      private
      #######

      # Returns the translation_file or nil
      def translation_file(argv=@argv)
        argv[2] if argv.length >= 3 and File.exist?(argv[2]) and !File.directory?(argv[2])
      end

      # Returns action (command) user is calling or ''
      def action(argv=@argv)
        @argv.try(:[],0) || ''
      end

      # Returns the config file
      def config_file(argv=@argv)
        @config_file ||= Configuration.parse(argv[1]) if argv.length >= 2 and File.exist?(argv[1]) and !File.directory?(argv[1])
      end

      # option parser, ensuring parse_options is only called once
      def parse_options
        @parser.parse!(@argv)
      rescue OptionParser::InvalidOption => er
        raise Mongify::InvalidOption, er.message, er.backtrace
      end
    end
  end
end
