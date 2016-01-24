require 'mongify/translation/processor_common'
module Mongify
  class Translation
    #
    # This module does the sync processing on the translation object
    #
    include ProcessorCommon
    module Sync
      attr_accessor :max_updated_at
      DRAFT_KEY = "__mongify_sync_draft__"
      SYNC_HELPER_TABLE = "__mongify_sync_helper__"

      class SyncHelperMigrator < ActiveRecord::Migration
        def up
          create_table SYNC_HELPER_TABLE, :id => false do |t|
            t.string :table_name
            t.datetime :last_updated_at
          end
          add_index SYNC_HELPER_TABLE, :table_name
        end
      end

      # Does the actual act of sync processing the translation.
      # Takes in both a sql connection and a no sql connection
      def sync(sql_connection, no_sql_connection)
        prepare_connections(sql_connection, no_sql_connection)
        setup_sync_table
        setup_db_index
        sync_data
        set_last_updated_at
        copy_embedded_tables
        sync_update_reference_ids
        copy_polymorphic_tables
        nil
      end

      #######
      private
      #######

      def setup_sync_table
        # make sure table exists
        begin
          self.sql_connection.execute("SELECT count(*) FROM #{SYNC_HELPER_TABLE}")
        rescue
          SyncHelperMigrator.new.up
        end
        # insert missing records for sync tables
        self.copy_tables.each do |t|
          if self.sql_connection.count(SYNC_HELPER_TABLE, "table_name = '#{t.sql_name}'") == 0
            self.sql_connection.execute("INSERT INTO #{SYNC_HELPER_TABLE} (table_name, last_updated_at) VALUES ('#{t.sql_name}', '1970-01-01')")
          end
        end
      end

      # Does the straight copy (of tables)
      def sync_data
        self.copy_tables.each do |t|
          q = "SELECT t.* FROM #{t.sql_name} t, #{SYNC_HELPER_TABLE} u " +
            "WHERE t.updated_at > u.last_updated_at AND u.table_name = '#{t.sql_name}'"
          rows = sql_connection.select_by_query(q)
          Mongify::Status.publish('copy_data', :size => rows.count, :name => "Syncing #{t.name}", :action => 'add')
          max_updated_at, max_updated_at_id = Time.new(1970), nil
          rows.each do |row|
            row_hash = t.translate(row)
            updated_at = row['updated_at']
            updated_at = Time.parse(updated_at) if updated_at.instance_of?(String)
            if updated_at > max_updated_at
              max_updated_at = updated_at
              max_updated_at_id = row_hash['pre_mongified_id']
            end
            no_sql_connection.upsert(t.name, row_hash.merge({DRAFT_KEY => true}))
            Mongify::Status.publish('copy_data')
          end
          raise "Table #{t.sql_name} must have a primary key denoted by :key in the translation file" if t.key_column.nil?
          (self.max_updated_at ||= {})[t.sql_name] = {'max_updated_at_id' => max_updated_at_id, 'key_column' => t.key_column.name}
          Mongify::Status.publish('copy_data', :action => 'finish')
        end
      end

      # Updates the reference ids in the no sql database
      def sync_update_reference_ids
        self.copy_tables.each do |t|
          rows = no_sql_connection.select_by_query(t.name, {DRAFT_KEY => true})
          Mongify::Status.publish('update_references', :size => rows.count, :name => "Updating References #{t.name}", :action => 'add')
          rows.each do |row|
            id = row["_id"]
            attributes = fetch_reference_ids(t, row)
            setter = {"$unset" => {DRAFT_KEY => true}}
            setter["$set"] = attributes unless attributes.blank?
            no_sql_connection.update(t.name, id, setter)
            Mongify::Status.publish('update_references')
          end
          Mongify::Status.publish('update_references', :action => 'finish')
        end
      end

      # Sets the last updated_at flag so that next sync doesn't unnecessarily copy old data
      def set_last_updated_at
        tables = self.copy_tables
        Mongify::Status.publish('set_last_updated_at', :size => tables.length, :name => "Setting last_updated_at", :action => 'add')
        tables.each do |t|
          info = self.max_updated_at[t.sql_name]
          if info && info['max_updated_at_id']
            sql_connection.execute("UPDATE #{SYNC_HELPER_TABLE} SET last_updated_at = (SELECT updated_at FROM #{t.sql_name} WHERE #{info['key_column']} = '#{info['max_updated_at_id']}') WHERE table_name = '#{t.sql_name}'")
          end
          Mongify::Status.publish('set_last_updated_at')
        end
        Mongify::Status.publish('set_last_updated_at', :action => 'finish')
      end

    end
  end
end
