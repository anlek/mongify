$:.push File.expand_path("../lib", __FILE__)
require "mongify/version"

Gem::Specification.new do |s|
  s.name        = "mongify"
  s.version     = Mongify::VERSION
  s.platform    = Gem::Platform::RUBY
  s.authors     = ["Andrew Kalek"]
  s.email       = ["andrew.kalek@anlek.com"]
  s.homepage    = "http://github.com/anlek/mongify"
  s.summary     = %q{Translate your SQL data to MongoDB}
  s.description = %q{Mongify allows you to map your data from a sql database and into a mongodb document database.}

  s.default_executable = "mongify"

  s.add_dependency('activerecord', ">= 2.3.10")
  s.add_dependency('activesupport', ">= 2.3.10")
  s.add_dependency('net-ssh', ">= 2.0")

  s.add_development_dependency('rspec', '>= 2.0')
  s.add_development_dependency('rcov', '>= 0.9.9')
  s.add_development_dependency('cucumber', '>= 0.10')
  s.add_development_dependency('mocha', '>= 0.9.8')
  s.add_development_dependency('yard', '>= 0.5.3')
  s.add_development_dependency('watchr', '>= 0.6')
  s.add_development_dependency('sqlite3-ruby', '>= 1.3')
  s.add_development_dependency('mysql', '>= 2.8.1')

  s.files         = `git ls-files`.split("\n")
  s.test_files    = `git ls-files -- {test,spec,features}/*`.split("\n")
  s.executables   = `git ls-files -- bin/*`.split("\n").map{ |f| File.basename(f) }
  s.require_paths = ["lib"]


  s.extra_rdoc_files = [
    "CHANGELOG.rdoc",
    "README.rdoc"
  ]
  s.rdoc_options = ["--title", "Mongify -- SQL db to Mongo db converter", "--main", "README", "--line-numbers", "--inline-source"]
end
