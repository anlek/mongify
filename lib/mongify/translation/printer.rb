module Mongify
  class Translation
    #
    # Actually runs the translation from sql to no sql
    #
    module Printer
      # Outputs a translation into a string format
      def print
        ''.tap do |output|
          all_tables.each do |t|
            output << %Q[table "#{t.name}" do\n]
              t.columns.each do |c|
                output << "\t#{c.to_print}\n"
              end
            output << "end\n\n"
          end
        end
      end
    end
  end
end