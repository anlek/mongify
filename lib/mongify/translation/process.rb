module Mongify
  #
  # This will take the Translation and do the processing on it
  #
  class Translation
    module Process
      def sql_connection=(value)
        @sql_connection=value
      end
      def no_sql_connection=(value)
        @no_sql_connection=value
      end
      def process(sql_connection, no_sql_connection)
        raise Mongify::SqlConnectionRequired, "Can only read from Mongify::Database::SqlConnection" unless sql_connection.is_a?(Mongify::Database::SqlConnection)
        raise Mongify::NoSqlConnectionRequired, "Can only write to Mongify::Database::NoSqlConnection" unless no_sql_connection.is_a?(Mongify::Database::NoSqlConnection)
        
        self.sql_connection = sql_connection
        raise "SQL Connection is not valid" unless self.sql_connection.valid?
        self.no_sql_connection = no_sql_connection
        raise "noSql Connection is not valid" unless self.no_sql_connection.valid?
        
        copy
        update_reference_ids
        nil
      end
      
      #######
      private
      #######
      
      def copy
        self.tables.each do |t|
          sql_connection.select_rows(t.name).each do |row|
            no_sql_connection.insert_into(t.name, t.translate(row))
          end
        end
      end
      
      def update_reference_ids
        self.tables.each do |t|
          no_sql_connection.select_rows(t.name).each do |row|
            id = row["_id"]
            attributes = {}
            t.reference_columns.each do |c|
              new_id = no_sql_connection.get_id_using_pre_mongified_id(c.references.to_s, row[c.name])
              attributes.merge!(c.name => new_id) unless new_id.nil?
            end
            no_sql_connection.update(t.name, id, {"$set" => attributes}) unless attributes.blank?
          end
        end
      end
      
    end
  end
end


# Process that needs to take place
#   import the data (moving the id to premongified_id)   
#   fix all the references to the new ids
#   