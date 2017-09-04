module Mongify
  # Module that deals with all database related items
  module Database
    #
    # This is a Basic configuration for any sql or non sql database
    #
    class BaseConnection
      # List of required fields to make a valid base connection
      REQUIRED_FIELDS = %w[host].freeze
      # List of all the available fields to make up a connection
      AVAILABLE_FIELDS = %w[
        adapter
        host
        username
        password
        database
        socket
        port
        encoding
        batch_size
      ].freeze
      # List of all fields that should be forced to a string
      STRING_FIELDS = %w[adapter].freeze

      def initialize(options=nil)
        if options
          options.stringify_keys!
          options.each do |key, value|
             instance_variable_set "@#{key.downcase}", value if AVAILABLE_FIELDS.include?(key.downcase)
          end
        end
      end

      # Returns all settings as a hash, this is used mainly in building
      # ActiveRecord::Base.establish_connection
      def to_hash
        hash = {}
        instance_variables.each do |variable|
          value = instance_variable_get variable
          hash[variable.to_s.delete('@').to_sym] = value unless value.nil?
        end
        hash
      end

      # Ensures the required fields are filled
      def valid?
        # TODO: Improve this to create an errors array with detailed errors
        # (or maybe just use activemodel)
        REQUIRED_FIELDS.each do |require_field|
          return false unless instance_variables.map(&:to_s).include?("@#{require_field}") and
                              !instance_variable_get("@#{require_field}").to_s.empty?
        end
        true
      end

      # Used to setup connection, Raises NotImplementedError because it
      # needs to be setup in BaseConnection's children
      def setup_connection_adapter
        raise NotImplementedMongifyError
      end

      # Used to test connection, Raises NotImplementedError because it needs to
      # be setup in BaseConnection's children
      def has_connection?
        raise NotImplementedMongifyError
      end


      # Returns true if we are trying to respond_to AVAILABLE_FIELDS functions
      def respond_to?(method, *args)
        return true if AVAILABLE_FIELDS.include?(method.to_s)
        super(method)
      end

      # Building set and/or return functions for AVAILABLE_FIELDS.
      # STRING_FIELDS are forced into string.
      # Example:
      #
      #   def host(value=nil)
      #     @host = value.to_s unless value.nil?
      #     @host
      #   end
      #
      def method_missing(method, *args)
        method_name = method.to_s
        if AVAILABLE_FIELDS.include?(method_name.to_s)

          if STRING_FIELDS.include?(method_name.to_s)
            assignment = "@#{method_name} = value.to_s"
          else
            assignment = "@#{method_name} = value"
          end

          class_eval <<-EOF
                          def #{method_name}(value=nil)
                            #{assignment} unless value.nil?
                            @#{method_name}
                          end
                        EOF
          value = args.first if args.size > 0
          send(method,value)
        else
          super(method, args)
        end

      end

    end
  end
end
