$:.push File.expand_path("../lib", __FILE__)
require "mongify/version"

Gem::Specification.new do |s|
  s.name        = "mongify"
  s.version     = Mongify::VERSION
  s.platform    = Gem::Platform::RUBY
  s.authors     = ["Andrew Kalek"]
  s.email       = ["andrew.kalek@anlek.com"]
  s.homepage    = "http://mongify.com"
  s.summary     = %q{Translate your SQL data to MongoDB with ease}
  s.description = %q{Mongify allows you to map your sql data into a mongodb document database with a simple DSL.}
  s.required_ruby_version = ">= 1.8.7"

  s.add_dependency('activerecord', "~> 3.2")
  s.add_dependency('activesupport', "~> 3.2")
  s.add_dependency('mongo', "~> 1.8.2")
  s.add_dependency('bson_ext', "~> 1.8.2") unless RUBY_PLATFORM == 'java'
  s.add_dependency('highline', '>= 1.6.1')


  s.add_development_dependency('rspec', '>= 2.0')
  s.add_development_dependency('cucumber', '>= 0.10')
  s.add_development_dependency('mocha', '>= 0.9.8')
  s.add_development_dependency('yard', '>= 0.5.3')
  s.add_development_dependency('sqlite3-ruby', '>= 1.3')
  s.add_development_dependency('mysql2', '~> 0.2.7')
  s.add_development_dependency('watchr', '>= 0.6')
  s.add_development_dependency('rake')

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
