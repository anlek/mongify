module Mongify
  module Database
    # Class that will be used to allow user to modify data for the given row
    class DataRow
      def initialize(hash={})
        hash = {} if hash.nil?
        @hash = hash.dup.stringify_keys!
      end

      # See if a given key is included
      def include?(key)
        @hash.has_key?(key.to_s)
      end

      # Deletes a given key from the object
      def delete(key)
        @hash.delete(key.to_s)
      end

      # Returns a list of available keys
      def keys
        @hash.keys
      end

      # Outputs an hash
      # This is used to write into the no sql database
      def to_hash
        @hash
      end

      # Used to manually read an attribute
      def read_attribute(key)
        @hash[key.to_s]
      end
      # Used to manually write an attribute
      def write_attribute(key, value)
        @hash[key.to_s] = value
      end

      # Passes Inspect onto the internal hash
      def inspect
        @hash.inspect
      end

      # Updated respond_to to return true if it's a key the hash
      def respond_to?(method)
        return true if @hash.has_key?(method.gsub('=', ''))
        super(method)
      end

      # Added the ability to read and write attributes in the hash
      def method_missing(meth, *args, &blk)
        match = meth.to_s.match(/^([a-zA-Z\_]+)(=|$)$/)
        if match
          attribute, setter = match[1], !match[2].blank?
          if setter
            write_attribute(attribute, args.first)
          else
            read_attribute(attribute)
          end
        else
          super(meth, *args, &blk)
        end
      end

    end
  end
end