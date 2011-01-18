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
        
        copy_data
        copy_embedded_tables
        update_reference_ids
        remove_pre_mongified_ids
        nil
      end
      
      #######
      private
      #######
      
      def copy_data
        self.copy_tables.each do |t|
          sql_connection.select_rows(t.name).each do |row|
            no_sql_connection.insert_into(t.name, t.translate(row))
          end
        end
      end
      
      def copy_embedded_tables
        self.embed_tables.each do |t|
          sql_connection.select_rows(t.name).each do |row|
            target_row = no_sql_connection.find_one(t.embed_in, {:pre_mongified_id => row[t.embed_on]})
            next unless target_row.present?
            row = t.translate(row)
            row.delete(t.embed_on)
            row.merge!(fetch_reference_ids(t, row))
            row.delete('pre_mongified_id')
            save_function_call = t.embed_as_object? ? '$set' : '$addToSet'
            no_sql_connection.update(t.embed_in, target_row['_id'], {save_function_call => {t.name => row}})
          end
        end
      end
      
      def update_reference_ids
        self.tables.each do |t|
          no_sql_connection.select_rows(t.name).each do |row|
            id = row["_id"]
            attributes = fetch_reference_ids(t, row)
            no_sql_connection.update(t.name, id, {"$set" => attributes}) unless attributes.blank?
          end
        end
      end
      
      def fetch_reference_ids(table, row)
        attributes = {}
        table.reference_columns.each do |c|
          new_id = no_sql_connection.get_id_using_pre_mongified_id(c.references.to_s, row[c.name])
          attributes.merge!(c.name => new_id) unless new_id.nil?
        end
        attributes
      end
      
      def remove_pre_mongified_ids
        self.copy_tables.each { |t| no_sql_connection.remove_pre_mongified_ids(t.name) }
      end
      
    end
  end
end