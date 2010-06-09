require File.join(File.dirname(File.dirname(File.dirname(File.expand_path(__FILE__)))), 'core_ext', 'hash')
require 'dm-core'

module Mongify
  module Database
    #
    # Basic configuration for any sql or non sql database
    #
    class BaseConfig
      
      REQUIRED_FIELDS = %w{host}
      AVAILABLE_FIELDS = %w{adaptor host username password database socket port}
      
      def initialize(options=nil)
        if options
          options.stringify_keys!
          options.each do |key, value|
            instance_variable_set "@#{key}", value
          end
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
          return false unless instance_variables.include?("@#{require_field}") and
                              !instance_variable_get("@#{require_field}").to_s.empty?
        end
        true
      end
      
      def connection_string
        ""
      end
      
      def dm_connection
        @dm_connection = DataMapper.setup(self.class.to_s.to_sym, connection_string)
      end
      
      def connects?
        raise NotImplementedError
      end
      
      def respond_to?(method)
        return true if AVAILABLE_FIELDS.include?(method.to_s)
        super(method)
      end
      
      def method_missing(method, *args)
        if AVAILABLE_FIELDS.include?(method.to_s)
          value = args.first rescue nil
          instance_eval "def #{method}(value);@#{method}=value;end"
          send(method, value)
        else
          super(method, args)
        end
        
      end
        
    end
  end
end