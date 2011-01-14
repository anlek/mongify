module Mongify
  module Database
    #
    # A column in the sql table
    #
    class Column
      attr_reader :name, :type, :options
      
      AVAILABLE_OPTIONS = ['references', 'default']

      def initialize(name, type=:string, *args)
        @name = name
        type = :string if type.nil?
        @type = type.is_a?(Symbol) ? type : type.to_sym
        @options = args.extract_options!.stringify_keys
        
        auto_detect!
        
        self
      end
      
      def translate(value)
        if key?
          return {"pre_mongified_#{name}" => value, "#{name}" => nil}
        end
        {"#{self.name}" => value}
      end
      
      def to_print
        "column \"#{name}\", :#{type}".tap do |output|
          output_options = options.map{|k, v| (v == nil) ? nil : ":#{k} => \"#{v}\""}.compact
          output << ", #{output_options.join(', ')}" unless output_options.blank?
        end
      end
      
      def method_missing(meth, *args, &blk)
        method_name = meth.to_s.gsub("=", '')
        if AVAILABLE_OPTIONS.include?(method_name)
          class_eval <<-EOF
                          def #{method_name}=(value)
                            options['#{method_name}'] = value
                          end
                          def #{method_name}
                            options['#{method_name}']
                          end
                        EOF
          send(meth, *args, &blk)
        else
          super(meth, *args, &blk)
        end
      end
      
      #######
      private
      #######
      
      def key?
        self.type == :key
      end

      def auto_detect!
        case name.downcase
        when 'id'
          @type = :key if self.type == :integer
        when /(.*)_id/
          self.references = $1.to_s.pluralize unless self.references
        end
      end
      
      
    end
  end
end