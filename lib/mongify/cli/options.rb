module Mongify
  #
  # Parses the command line
  #
  class CLI
    module Options
      module ClassMethods
        # Return a new CLI instance with the given arguments pre-parsed and
        # ready for execution.
        def parse(args)
          cli = new(args)
          cli
        end
      end
      
      def self.included(receiver)
        receiver.extend(ClassMethods)
      end
      
      
      # The hash of (parsed) command-line options
      attr_reader :options
      
      
      def option_parser
        @option_parser ||= OptionParser.new do |opts|
          script_name = File.basename($0)
          opts.banner = "USAGE: #{script_name} command [database_structure.rb]"
          
          opts.on('-d', '--debug', 'Run application in debug mode') { |value| options[:debug] = true }
                    
          opts.on("-h", "--help", "Show this message") do
            UI.puts opts
            exit
          end

          # Another typical switch to print the version.
          opts.on("-v","--version", "Show version") do
            UI.puts "#{script_name} version: #{Mongify::Version::STRING}"
            exit
          end


          @help_text = opts.to_s
          @help_text << %Q{
COMMANDS: #{script_name} process database_translation.rb
          #{script_name} check database_translation.rb
          }
        end
      end
      
      def parse_options!
        @options = {}
        
        option_parser.parse!(args)
        
        if args.length <= 1
          warn "Please specify an action and a file."
          warn option_parser
          exit
        end
                
        self.command = args[0]
        self.file_path = File.expand_path(args[1])

        if !File.exists?(self.file_path)
          warn "#{self.file_path}' does not exist."
          exit
        elsif !File.file?(self.file_path)
          warn "#{self.file_path}' is not a file."
          exit
        elsif args.length > 2
          warn "Too many arguments;"
          warn option_parser
          exit
        end
      end      
    end
  end
end