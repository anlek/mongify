require 'mongify/translation/base_config'

module Mongify
  class Translation
    class SqlConfig < Mongify::Translation::BaseConfig
          
      REQUIRED_FIELDS = %w{host adaptor database}  
      
      def connection_string
        if(@username && @password)
          "#{@adaptor}://#{@username}:#{@password}@#{@host}/#{@database}"
        else
          "#{@adaptor}://#{@host}/#{@database}"
        end
      end
      
    end
  end
end