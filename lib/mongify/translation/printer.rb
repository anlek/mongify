module Mongify
  #
  # Actually runs the translation from sql to no sql
  #
  class Translation
    module Printer
      def print
        output = ''
        @tables.each do |t|
          output << %Q[table "#{t.name}" do\n]
          t.columns.each do |c|
            output << %Q[  column "#{c.name}", :#{c.type}#{ ", #{c.options.inspect.gsub(/[\{\}]/, '')}" unless c.options.blank?}\n]
          end
          output << "end\n\n"
        end
        return output
      end
    end
  end
end