require 'optparse'
module Mongify
  class Runner
    def initialize(arguments, stdin, stdout)
      @arguments = arguments
      @stdin = stdin
      @stdout = stdout
    end
    
    def run
      Config.in_stream = @stdin
      Config.out_stream = @stdout
      parse_options
      parse_arguments
    end
    
    #######
    private
    #######
    
    def parse_options
      OptionParser.new do |opts|
        script_name = 'mongify'
        opts.banner = "USAGE: #{script_name} command [database_structure.rb]"

        opts.on_tail("-h", "--help", "Show this message") do
          UI.puts @help_text
          exit
        end

        # Another typical switch to print the version.
        opts.on_tail("-v","--version", "Show version") do
          UI.puts "#{script_name} version: #{Mongify::Version::STRING}"
          exit
        end


        @help_text = opts.to_s
        @help_text << %Q{
COMMANDS: #{script_name} process database_translation.rb
          #{script_name} check database_translation.rb
        }

        begin
          opts.parse!(@arguments)
        rescue OptionParser::ParseError => e
          warn e.message
          UI.puts opts
          exit 1
        end
      end
    end
    
    def parse_arguments
      if @arguments.length <= 1
        abort @help_text
      end

      @command = @arguments[0]
      @file_path = File.expand_path(@arguments[1])

      if !File.exists?(@file_path)
        abort "`#{@file_path}' does not exist."
      elsif !File.file?(@file_path)
        abort "`#{@file_path}' is not a file."
      elsif @arguments.length > 2
        abort "Too many arguments;\n#{@help_text}"
      end

      Config.file_path = @file_path
      
      case @command 
        when 'process'
          UI.puts "Processing..."
          UI.puts "FUNCTION NOT COMPLETE!"
        when 'check'
          UI.puts "Checking..."
          UI.puts "FUNCTION NOT COMPLETE!"
        else
          abort "Unknown Process\n #{@help_text}"
      end
      
      UI.puts "[DONE]"
    end
    
  end
end


      # @file_path = file_path
      # @file_name = File.basename(file_path, ".rb")
      # puts "File PATH #{@file_path}"
      # puts "File NAME #{@file_name}"