module Mongify
  class Translation
    #
    # Used to generate translation from a sql_config
    #
    class Generator
      def initialize(config)
        raise "Can only generate from SqlConfig" unless config.is_a?(SqlConfig)
      end
       
      def for_table(name)
        
      end
    end
  end
end