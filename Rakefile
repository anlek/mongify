require 'rake'
require 'spec/rake/spectask'
require "lib/mongify"

begin
  require 'echoe'
rescue LoadError
  abort "You'll need to have `echoe' installed to use Capistrano's Rakefile"
end
 
version = Mongify::VERSION
if ENV['SNAPSHOT'].to_i == 1
  version << "." << Time.now.utc.strftime("%Y%m%d%H%M%S")
end

Echoe.new('mongify', version) do |p|
  p.changelog            = 'CHANGELOG.rdoc'
  
  p.author                = 'Andrew Kalek'
  p.email                 = 'andrew.kalek@anlek.com'
  
  p.ignore_pattern = ["tmp/*", "script/*", "Examples/*"]
  
  p.summary = <<-DESC.strip.gsub(/\n\s+/, " ")
    Mongify allows you to map your data from a sql database and into a mongodb document database.
  DESC
  
  p.url = "http://github.com/anlek/mongify"
  p.rdoc_pattern = /^(lib|README.rdoc|CHANGELOG.rdoc|LICENSE)/
  
  p.development_dependencies = ['rspec >=1.3', 
                                'mocha >=0.9.8', 
                                'yard >=0.5.3']
  p.runtime_dependencies = ['activerecord >=2.3', 'net-ssh >=2.0']
end
 
spec_files = Rake::FileList["spec/**/*_spec.rb"]
 
task :default => :spec

Dir["#{File.dirname(__FILE__)}/tasks/*.rake"].sort.each { |ext| load ext }