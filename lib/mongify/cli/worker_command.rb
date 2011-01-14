module Mongify
  module CLI

    #
    # A command to run the different commands in the application (related to Mongifying).
    #
    class WorkerCommand
      attr_accessor :view
      
      AVAILABLE_COMMANDS = {
                                :check => {:commands => ['check', 'ck'], :description => "Checks connection for sql and no_sql databases", :required => [:configuration_file]},
                                :translate => {:commands => ['translate', 'tr'], :description => "Spits out translation from a sql connection", :required => [:configuration_file]},
                                :process => {:commands => ['process', 'pr'], :description => "Takes a translation and process it to mongodb", :required => [:configuration_file, :translation_file]}
                              }
      def self.list_commands
        [].tap do |commands|
          AVAILABLE_COMMANDS.each do |key, obj|
            commands << "#{obj[:commands].map{|w| %["#{w}"]}.to_sentence(:two_words_connector => ' or ', :last_word_connector => ', or ').ljust(25)} >> #{obj[:description]}#{ " [#{obj[:required].join(', ')}]" if obj[:required]}"
          end
        end.sort
      end
                              
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
      
      def execute(view)
        self.view = view
        
        current_command, command_options = find_command
        
        if command_options
          #FIXME: Should parse configuration file in this action, (when I know it's required)
          raise ConfigurationFileNotFound, "Configuration file is required" if command_options[:required] && command_options[:required].include?(:configuration_file) && @config.nil?
          if command_options[:required] && command_options[:required].include?(:translation_file)
            raise TranslationFileNotFound, "Translation file is required for command '#{current_command}'" unless @translation_file
            raise TranslationFileNotFound, "Unable to find Translation File at #{@translation_file}" unless File.exists?(@translation_file)
            @translation = Translation.parse(@translation_file)
          end
        end
        
        case current_command
        when :translate
          check_connections
          view.output(Mongify::Translation.load(@config.sql_connection).print)
        when :check
          view.output("SQL connection works") if check_sql_connection
          view.output("NoSQL connection works") if check_nosql_connection
        when :process
          check_connections
          @translation.process(@config.sql_connection, @config.no_sql_connection)
        else
          view.output("Unknown action #{@command}\n\n#{@parser}")
          view.report_error
          return
        end
        view.report_success
      end
      
      def find_command(command=@command)
        self.class.find_command(command)
      end
      
      #######
      private
      #######

      def check_connections(sql_only = false)
        check_sql_connection && (sql_only || check_nosql_connection)
      end
      
      def check_sql_connection
        @config.sql_connection.valid? && @config.sql_connection.has_connection?
      end
      
      def check_nosql_connection
        @config.no_sql_connection.valid? && @config.no_sql_connection.has_connection?        
      end
      
      
    end
  end
end
