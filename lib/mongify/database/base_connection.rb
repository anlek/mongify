module Mongify
  module Database
    #
    # Basic configuration for any sql or non sql database
    #
    class BaseConnection

      REQUIRED_FIELDS = %w{host}
      AVAILABLE_FIELDS = %w{adapter host username password database socket port encoding}

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


      def setup_connection_adapter
        raise NotImplementedError
      end

      def has_connection?
        raise NotImplementedError
      end

      def adapter(value=nil)
        @adapter = value.to_s unless value.nil?
        @adapter
      end


      def respond_to?(method, *args)
        return true if AVAILABLE_FIELDS.include?(method.to_s)
        super(method)
      end

      def method_missing(method, *args)
        method_name = method.to_s #.gsub("=", '')
        if AVAILABLE_FIELDS.include?(method_name.to_s)
          class_eval <<-EOF
                          def #{method_name}(value=nil)
                            @#{method_name} = value unless value.nil?
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