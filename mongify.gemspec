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

  s.add_runtime_dependency('activerecord', ">= 4.2", "< 5.0")
  s.add_runtime_dependency('activesupport', ">= 4.2", "< 5.0")
  s.add_runtime_dependency('mongo', "= 1.12.5")
  s.add_runtime_dependency('bson', "= 1.12.5")
  s.add_runtime_dependency('bson_ext', "= 1.12.5") unless RUBY_PLATFORM == 'java'
  s.add_runtime_dependency('highline', '= 1.7.8')


  s.add_development_dependency('rspec', '~> 2.0')
  s.add_development_dependency('rspec-collection_matchers', '~> 1.0')
  s.add_development_dependency('cucumber', '>= 0.10')
  s.add_development_dependency('mocha', '>= 0.9.8')
  s.add_development_dependency('yard', '~> 0.9.11')
  s.add_development_dependency('sqlite3', '>= 1.3')
  s.add_development_dependency('pg', '>= 0.17')
  s.add_development_dependency('mysql2', '>= 0.4.10')
  s.add_development_dependency('watchr', '>= 0.6')
  s.add_development_dependency('rake')
  s.add_development_dependency('jazz_fingers')

  s.files         = `git ls-files`.split("\n")
  s.test_files    = `git ls-files -- {test,spec,features}/*`.split("\n")
  s.executables   = `git ls-files -- bin/*`.split("\n").map{ |f| File.basename(f) }
  s.require_paths = ["lib"]

  s.extra_rdoc_files = [
    "CHANGELOG.md",
    "README.rdoc"
  ]
  s.rdoc_options = ["--title", "Mongify -- SQL db to Mongo db converter", "--main", "README", "--line-numbers", "--inline-source"]
end
