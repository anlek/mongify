require File.join(File.dirname(File.dirname(File.dirname(File.expand_path(__FILE__)))), 'core_ext', 'hash')

module Mongify
  module Database
    #
    # Basic configuration for any sql or non sql database
    #
    class BaseConfig
      
      REQUIRED_FIELDS = %w{host}
      
      def initialize(options=nil)
        return unless options
        options.stringify_keys!
        options.each do |key, value|
          instance_variable_set "@#{key}", value
        end
      end
      
      def to_hash
        hash = {}
        instance_variables.each do |variable|
          value = self.instance_variable_get variable
          hash[variable.gsub('@','').to_sym] = value unless value.nil?
        end
        hash
      end
      
      def valid?
        REQUIRED_FIELDS.each do |require_field|
          return false unless instance_variables.include?("@#{require_field}")
        end
        true
      end
      
      def method_missing(method, value=nil)
        instance_eval "def #{method}(value);@#{method}=value;end"
        send(method, value)
      end
        
    end
  end
end