module Mongify
  class CLI
    module Execute
      def self.included(receiver)
        receiver.extend ClassMethods
      end
      
      module ClassMethods
        def execute
          parse(ARGV).execute!
        end
      end
            
      
      
      def execute!
        case self.command
          when 'process'
            UI.puts "Processing..."
            UI.puts "FUNCTION NOT COMPLETE!"
          when 'check'
            UI.puts "Checking..."
            UI.puts "FUNCTION NOT COMPLETE!"
          else
            warn "Unknown Process #{self.command}"
            exit
        end

        UI.puts "[DONE]"
      end
    end
  end
  
end