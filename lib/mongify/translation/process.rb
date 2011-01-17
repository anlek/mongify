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
        p = ProgressBar.new('Copying Tables', self.copy_tables.count)
        self.copy_tables.each do |t|
          sql_connection.select_rows(t.name).each do |row|
            no_sql_connection.insert_into(t.name, t.translate(row))
          end
          p.inc
        end
        p.finish
      end
      
      def copy_embedded_tables
        p = ProgressBar.new('Copying Embedded Tables', self.embed_tables.count)
        self.embed_tables.each do |t|
          sql_connection.select_rows(t.name).each do |row|
            target_row = no_sql_connection.find_one(t.embed_in, {:pre_mongified_id => row[t.embed_on]})
            next unless target_row.present?
            row = t.translate(row)
            row.delete(t.embed_on)
            row.merge!(fetch_reference_ids(t, row))
            row.delete('pre_mongified_id')
            no_sql_connection.update(t.embed_in, target_row['_id'], {'$addToSet' => {t.name => row}})
          end
          p.inc
        end
        p.finish
      end
      
      def update_reference_ids
        p = ProgressBar.new('Updating Reference IDs', self.tables.count)
        self.tables.each do |t|
          no_sql_connection.select_rows(t.name).each do |row|
            id = row["_id"]
            attributes = fetch_reference_ids(t, row)
            no_sql_connection.update(t.name, id, {"$set" => attributes}) unless attributes.blank?
          end
          p.inc
        end
        p.finish
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
        p = ProgressBar.new("Removed pre_mongified_ids", self.copy_tables.count)
        self.copy_tables.each { |t| no_sql_connection.remove_pre_mongified_ids(t.name); p.inc }
        p.finish
      end
      
    end
  end
end