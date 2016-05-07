require 'bundler'
Bundler::GemHelper.install_tasks

require 'cucumber/rake/task'
require 'rspec/core/rake_task'

task :cleanup_rcov_files do
  rm_rf 'coverage.data'
end

desc 'clobber generated files'
task :clobber do
  rm_rf "pkg"
  rm_rf "tmp"
end

if RUBY_VERSION.to_f == 1.8
  namespace :rcov do
    Cucumber::Rake::Task.new(:cucumber) do |t|
      t.rcov = true
      t.rcov_opts = %w{--exclude osx\/objc,gems\/,spec\/,features\/ --aggregate coverage.data}
      t.rcov_opts << %[-o "coverage"]
    end

    RSpec::Core::RakeTask.new(:rspec) do |t|
      t.rcov = true
      t.rcov_opts = %w{--exclude osx\/objc,gems\/,spec\/,features\/}
    end

    desc "Run both specs and features to generate aggregated coverage"
    task :all do |t|
      rm "coverage.data" if File.exist?("coverage.data")
      Rake::Task["rcov:cucumber"].invoke
      Rake::Task["rcov:rspec"].invoke
    end
  end
end

desc "Run rspec test"
task :test do
  Rake::Task["test:rspec"].invoke
  if RUBY_VERSION.to_f < 1.9
    Rake::Task["rcov:cucumber"].invoke
  else
    Rake::Task["test:cucumber"].invoke
  end
end
namespace :test do
  RSpec::Core::RakeTask.new(:rspec)
  Cucumber::Rake::Task.new(:cucumber)

  namespace :setup do
    task :environment do
      require 'mongify'
      require './spec/support/config_reader'
      require 'yaml'
    end

    desc "Setup a postgresql database based on the spec/support/database.yml settings (under postgresql)"
    task postgresql: :environment do
      require 'active_record'
      require 'pg'

      ::CONNECTION_CONFIG = ConfigReader.new('spec/support/database.yml')

      create_pg_database(CONNECTION_CONFIG)

      ActiveRecord::Base.establish_connection(CONNECTION_CONFIG.postgresql)
      conn = ActiveRecord::Base.connection

      build_tables(conn)

      puts "Database Setup Finished"
    end

    desc "Setup a mysql database based on the spec/support/database.yml settings"
    task mysql: :environment do
      require 'mysql2'
      require 'active_record'

      ::CONNECTION_CONFIG = ConfigReader.new('spec/support/database.yml')

      create_mysql_database(CONNECTION_CONFIG)

      ActiveRecord::Base.establish_connection(CONNECTION_CONFIG.mysql)
      conn = ActiveRecord::Base.connection

      build_tables(conn)

      puts "Database Setup Finished"
    end

    #######
    private
    #######

    def build_tables(conn)
      conn.create_table(:users, force: true) do |t|
        t.string :first_name, :last_name
        t.timestamps null: false
      end

      conn.create_table(:posts, force: true) do |t|
        t.string :title
        t.integer :owner_id
        t.text :body
        t.datetime :published_at
        t.timestamps null: false
      end

      conn.create_table(:comments, force: true) do |t|
        t.text :body
        t.integer :post_id
        t.integer :user_id
        t.timestamps null: false
      end
    end

    def create_mysql_database(config)
      client = Mysql2::Client.new(host: config.mysql["host"] || "localhost",
                                  username: config.mysql["username"] || "root",
                                  password: config.mysql["password"])

      client.query("CREATE DATABASE IF NOT EXISTS #{config.mysql["database"]}")
      client.close
    end

    def create_pg_database(config)
      client = PG.connect(host: config.postgresql["host"] || "localhost",
                          dbname: 'postgres',
                          user: config.postgresql["username"] || "root",
                          password: config.postgresql["password"])

      missing_db = client.exec("SELECT 1 FROM pg_database where datname='#{config.postgresql["database"]}'").values.empty?
      client.exec("CREATE DATABASE #{config.postgresql["database"]}") if missing_db
      client.flush
      client.close
    end
  end
end

task default: ['test']