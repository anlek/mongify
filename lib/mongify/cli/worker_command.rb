module Mongify
  module CLI

    #
    # A command to run the different commands in the application (related to Mongifying).
    #
    class WorkerCommand
      attr_accessor :view
      
      AVAILABLE_COMMANDS = {
                                :check => {:commands => ['check', 'ck'], :description => "Checks connection for sql and no_sql databases", :required => [:configuration_file]},
                                :translation => {:commands => ['translate', 'tr'], :description => "Spits out translation from a sql connection", :requires => [:configuration_file]}
                              }
      def self.list_commands
        [].tap do |commands|
          AVAILABLE_COMMANDS.each do |key, obj|
            commands << " #{obj[:commands].map{|w| %["#{w}"]}.to_sentence(:two_words_connector => ' or ', :last_word_connector => ', or ').ljust(25)} >> #{obj[:description]}#{ " [#{obj[:required]}]" if obj[:required]}"
          end
        end.sort
      end
                              
      def self.compute_command(command)
        AVAILABLE_COMMANDS.each do |key, options|
          return key if(options[:commands].include?(command.to_s.downcase))
        end
        'unknown'
      end
      
      def initialize(command, config=nil, translation=nil, parser="")
        @command = command.to_s.downcase
        @config = config
        @translatipon = translation
        @parser = parser
      end
      
      def execute(view)
        self.view = view
        case compute_command
        when :translation
          check_configuration
          view.output(Mongify::Translation.load(@config.sql_connection).print)
        when :check
          view.output("SQL connection works") if check_sql_connection
          view.output("NoSQL connection works") if check_nosql_connection
        else
          HelpCommand.new("Unknown action #{@command}\n\n#{@parser}").execute(view)
          view.report_error
          return
        end
        view.report_success
      end
      
      def compute_command(command=@command)
        self.class.compute_command(command)
      end
      
      #######
      private
      #######

      def check_configuration(sql_only = false)
        check_sql_connection && (sql_only || check_nosql_connection)
      end
      
      def check_sql_connection
        @config.sql_connection.valid? && @config.sql_connection.has_connection?
      end
      
      def check_nosql_connection
        true        
      end
      
      
    end
  end
end
