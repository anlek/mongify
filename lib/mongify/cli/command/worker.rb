module Mongify
  module CLI
    module Command
      #
      # A command to run the different commands in the application (related to Mongifying).
      #
      class Worker
        attr_accessor :view

        # A hash of available commands
        # Including description, additional shortcuts to run the commands and requirements to run the command
        AVAILABLE_COMMANDS = {
          :check => {
            :commands => ['check', 'ck'],
            :description => "Checks connection for sql and no_sql databases",
            :required => [:configuration_file]
          },
          :translation => {:commands => ['translation', 'tr'], :description => "Outputs a translation file from a sql connection", :required => [:configuration_file]},
          :process => {:commands => ['process', 'pr'], :description => "Takes a translation and process it to mongodb", :required => [:configuration_file, :translation_file]},
          :sync => {:commands => ['sync', 'sy'], :description => "Takes a translation and process it to mongodb, only syncs (insert/update) new or updated records based on the updated_at column", :required => [:configuration_file, :translation_file]}
        }

        # Prints out a nice display of the list of commands
        def self.list_commands
          [].tap do |commands|
            AVAILABLE_COMMANDS.each do |key, obj|
              commands << "#{obj[:commands].map{|w| %["#{w}"]}.to_sentence(:two_words_connector => ' or ', :last_word_connector => ', or ').ljust(25)} >> #{obj[:description]}#{ " [#{obj[:required].join(', ')}]" if obj[:required]}"
            end
          end.sort
        end

        # Finds a command array by any of the shortcut commands
        def self.find_command(command)
          AVAILABLE_COMMANDS.each do |key, options|
            return [key, options] if(options[:commands].include?(command.to_s.downcase))
          end
          'unknown'
        end

        def initialize(command, config=nil, translation_file=nil, parser="")
          @command = command.to_s.downcase
          @config = config
          @translation_file = translation_file
          @parser = parser
        end

        #Executes the worked based on a given command
        def execute(view)
          self.view = view

          current_command, command_options = find_command

          if command_options
            #FIXME: Should parse configuration file in this action, (when I know it's required)
            raise ConfigurationFileNotFound, "Database Configuration file is missing or cannot be found" if command_options[:required] && command_options[:required].include?(:configuration_file) && @config.nil?
            if command_options[:required] && command_options[:required].include?(:translation_file)
              raise TranslationFileNotFound, "Translation file is required for command '#{current_command}'" unless @translation_file
              raise TranslationFileNotFound, "Unable to find Translation File at #{@translation_file}" unless File.exists?(@translation_file)
              @translation = Translation.parse(@translation_file)
            end
          end

          case current_command
          when :translation
            check_connections
            view.output(Mongify::Translation.load(@config.sql_connection).print)
          when :check
            view.output("SQL connection works") if check_sql_connection
            view.output("NoSQL connection works") if check_nosql_connection
          when :process
            check_connections
            @translation.process(@config.sql_connection, @config.no_sql_connection)
          when :sync
            check_connections
            @translation.sync(@config.sql_connection, @config.no_sql_connection)
          else
            view.output("Unknown action #{@command}\n\n#{@parser}")
            return view.report_error
          end
          view.report_success
        end

        # Passes find command to parent class
        def find_command(command=@command)
          self.class.find_command(command)
        end

        #######
        private
        #######

        # Checks both sql and no sql connection
        def check_connections
          check_sql_connection && check_nosql_connection
        end

        # Checks sql connection if it's valid and has_connection?
        def check_sql_connection
          @config.sql_connection.valid? && @config.sql_connection.has_connection?
        end

        # Checks no sql connection if it's valid and has_connection?
        def check_nosql_connection
          @config.no_sql_connection.valid? && @config.no_sql_connection.has_connection?
        end
      end
    end
  end
end
