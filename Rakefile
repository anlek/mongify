require 'rake'
require 'spec/rake/spectask'
require "lib/mongify"

 
version = Mongify::VERSION
if ENV['SNAPSHOT'].to_i == 1
  version << "." << Time.now.utc.strftime("%Y%m%d%H%M%S")
end


begin
  require 'jeweler'
  Jeweler::Tasks.new do |gemspec|
    gemspec.name = "mongify"
    gemspec.summary = "Move your data from a sql database to a mongodb document database."
    gemspec.description = <<-DESC.strip.gsub(/\n\s+/, " ")
      Mongify allows you to map your data from a sql database and into a mongodb document database.
    DESC
    gemspec.email = "andrew.kalek@anlek.com"
    gemspec.homepage = "http://github.com/anlek/mongify"
    gemspec.authors = ["Andrew Kalek"]
        
    gemspec.files = Dir['lib/**/*.rb'] + Dir['bin/*']
    gemspec.files += Dir['[A-Za-z\.]*']
    gemspec.extra_rdoc_files = ['README.rdoc', 'CHANGELOG.rdoc']
    gemspec.test_files = ['spec/*', 'features/*']
    
    gemspec.add_dependency('activerecord', '>= 2.3')
    gemspec.add_dependency('net-ssh', '>= 2.0')
    
    gemspec.add_development_dependency('jeweler', '>= 1.4')
    gemspec.add_development_dependency('rspec', '= 1.3')
    gemspec.add_development_dependency('mocha', '>= 0.9.8')
    gemspec.add_development_dependency('yard', '>= 0.5.3')
    gemspec.add_development_dependency('watchr', '>= 0.6')
    gemspec.add_development_dependency('sqlite3-ruby', '>= 1.3')
    gemspec.add_development_dependency('mysql', '>= 2.8.1')
    
    gemspec.version = version
    
    gemspec.rdoc_options << '--title' << 'Mongify -- SQL db to Mongo db' <<
                           '--main' << 'README' <<
                           '--line-numbers' << '--inline-source'
    
  end
rescue LoadError
  puts "Jeweler not available. Install it with: gem install jeweler"
end


spec_files = Rake::FileList["spec/**/*_spec.rb"]
 
desc "Run specs"
Spec::Rake::SpecTask.new do |t|
  t.spec_files = spec_files
  t.spec_opts = ["-c"]
end
 
task :default => :spec

Dir["#{File.dirname(__FILE__)}/tasks/*.rake"].sort.each { |ext| load ext }