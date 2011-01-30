module Mongify
  class Translation
    #
    # This module does the processing on the translation object
    #
    module Process
      attr_accessor :sql_connection, :no_sql_connection
      
      # Does the actual act of processing the translation.
      # Takes in boht a sql connection and a no sql connection
      def process(sql_connection, no_sql_connection)
        raise Mongify::SqlConnectionRequired, "Can only read from Mongify::Database::SqlConnection" unless sql_connection.is_a?(Mongify::Database::SqlConnection)
        raise Mongify::NoSqlConnectionRequired, "Can only write to Mongify::Database::NoSqlConnection" unless no_sql_connection.is_a?(Mongify::Database::NoSqlConnection)
        
        self.sql_connection = sql_connection
        raise "SQL Connection is not valid" unless self.sql_connection.valid?
        self.no_sql_connection = no_sql_connection
        raise "noSql Connection is not valid" unless self.no_sql_connection.valid?
        
        no_sql_connection.ask_to_drop_database if no_sql_connection.forced?
        
        copy_data
        copy_embedded_tables
        update_reference_ids
        copy_polymorphic_tables
        remove_pre_mongified_ids
        nil
      end
      
      #######
      private
      #######
      
      # Does the straight copy (of tables)
      def copy_data
        ActiveSupport::Notifications.instrument('mongify.copy_data.start', :size => self.copy_tables.count)
        self.copy_tables.each do |t|
          sql_connection.select_rows(t.sql_name).each do |row|
            no_sql_connection.insert_into(t.name, t.translate(row))
          end
          ActiveSupport::Notifications.instrument('mongify.copy_data.inc')
        end
        ActiveSupport::Notifications.instrument('mongify.copy_data.finish')
      end
      
      # Does a copy of the embedded tables
      def copy_embedded_tables
        ActiveSupport::Notifications.instrument('mongify.copy_embedded_tables.start', :size => self.embed_tables.count)
        self.embed_tables.each do |t|
          sql_connection.select_rows(t.sql_name).each do |row|
            target_row = no_sql_connection.find_one(t.embed_in, {:pre_mongified_id => row[t.embed_on]})
            next unless target_row.present?
            row = t.translate(row)
            row.delete(t.embed_on)
            row.merge!(fetch_reference_ids(t, row))
            row.delete('pre_mongified_id')
            save_function_call = t.embedded_as_object? ? '$set' : '$addToSet'
            no_sql_connection.update(t.embed_in, target_row['_id'], {save_function_call => {t.name => row}})
          end
          ActiveSupport::Notifications.instrument('mongify.copy_embedded_tables.inc')
        end
        ActiveSupport::Notifications.instrument('mongify.copy_embedded_tables.finish')
      end
      
      # Moves over polymorphic data
      def copy_polymorphic_tables
        ActiveSupport::Notifications.instrument('mongify.copy_polymorphic_tables.start', :size => self.polymorphic_tables.count)
        self.polymorphic_tables.each do |t|
          polymorphic_id_col, polymorphic_type_col = "#{t.polymorphic_as}_id", "#{t.polymorphic_as}_type"
          sql_connection.select_rows(t.sql_name).each do |row|
            table_name = row[polymorphic_type_col].tableize            
            new_id = no_sql_connection.get_id_using_pre_mongified_id(table_name, row[polymorphic_id_col])
            if new_id
              row = t.translate(row)
              row.merge!(fetch_reference_ids(t, row))
              row[polymorphic_id_col] = new_id
              row.delete('pre_mongified_id')
              if t.embedded?
                row.delete(polymorphic_id_col)
                row.delete(polymorphic_type_col)
                save_function_call = t.embedded_as_object? ? '$set' : '$addToSet'
                no_sql_connection.update(table_name, new_id, {save_function_call => {t.name => row}})
              else
                no_sql_connection.insert_into(t.name, row)
              end
            else
              UI.warn "#{table_name} table not found on #{t.sql_name} polymorphic import"
            end
          end
          ActiveSupport::Notifications.instrument('mongify.copy_polymorphic_tables.inc')
        end
        ActiveSupport::Notifications.instrument('mongify.copy_polymorphic_tables.finish')
      end
      
      # Updates the reference ids in the no sql database
      def update_reference_ids
        ActiveSupport::Notifications.instrument('mongify.update_reference_ids.start', :size => self.tables.size)
        self.tables.each do |t|
          no_sql_connection.select_rows(t.name).each do |row|
            id = row["_id"]
            attributes = fetch_reference_ids(t, row)
            no_sql_connection.update(t.name, id, {"$set" => attributes}) unless attributes.blank?
          end
          ActiveSupport::Notifications.instrument('mongify.update_reference_ids.inc')
        end
        ActiveSupport::Notifications.instrument('mongify.update_reference_ids.finish')
      end
      
      # Fetches the new _id from a collection
      def fetch_reference_ids(table, row)
        attributes = {}
        table.reference_columns.each do |c|
          new_id = no_sql_connection.get_id_using_pre_mongified_id(c.references.to_s, row[c.name])
          attributes.merge!(c.name => new_id) unless new_id.nil?
        end
        attributes
      end
      
      # Removes 'pre_mongiifed_id's from all collection
      def remove_pre_mongified_ids
        ActiveSupport::Notifications.instrument('mongify.remove_pre_mongified_ids.start', :size => self.tables.size)
        p = ProgressBar.new("Removed pre_mongified_ids", self.copy_tables.count)
        self.copy_tables.each do |t| 
          no_sql_connection.remove_pre_mongified_ids(t.name)
          ActiveSupport::Notifications.instrument('mongify.remove_pre_mongified_ids.inc')
        end
        ActiveSupport::Notifications.instrument('mongify.remove_pre_mongified_ids.finish')
      end
      
    end
  end
end