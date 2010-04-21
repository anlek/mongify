require File.join(File.dirname(File.dirname(File.dirname(File.dirname(File.expand_path(__FILE__))))), 'lib', 'mongify', 'database', 'base_config')

module Mongify
  module Database
    class SqlConfig < Mongify::Database::BaseConfig
          
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