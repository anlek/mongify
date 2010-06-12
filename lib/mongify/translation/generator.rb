require File.join(File.dirname(File.dirname(File.expand_path(__FILE__))), 'translation')


module Mongify
  class Translation
    #
    # Used to generate translation from a sql_config
    #
    class Generator
      def initialize(config)
        raise unless config.is_a?(SqlConfig)
      end
    end
  end
end