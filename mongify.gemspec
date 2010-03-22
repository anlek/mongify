# -*- encoding: utf-8 -*-

Gem::Specification.new do |s|
  s.name = %q{mongify}
  s.version = "0.0.1"

  s.required_rubygems_version = Gem::Requirement.new(">= 1.2") if s.respond_to? :required_rubygems_version=
  s.authors = ["Andrew Kalek"]
  s.date = %q{2010-03-22}
  s.default_executable = %q{mongify}
  s.description = %q{Mongify allows you to map your data from a sql database and into a mongodb document database.}
  s.email = %q{andrew.kalek@anlek.com}
  s.executables = ["mongify"]
  s.extra_rdoc_files = ["CHANGELOG.rdoc", "README.rdoc", "lib/mongify.rb", "lib/mongify/version.rb"]
  s.files = ["CHANGELOG.rdoc", "Manifest", "README.rdoc", "Rakefile", "bin/mongify", "lib/mongify.rb", "lib/mongify/version.rb", "mongify.gemspec", "spec/spec_helper.rb"]
  s.homepage = %q{http://github.com/anlek/mongify}
  s.rdoc_options = ["--line-numbers", "--inline-source", "--title", "Mongify", "--main", "README.rdoc"]
  s.require_paths = ["lib"]
  s.rubyforge_project = %q{mongify}
  s.rubygems_version = %q{1.3.6}
  s.summary = %q{Mongify allows you to map your data from a sql database and into a mongodb document database.}

  if s.respond_to? :specification_version then
    current_version = Gem::Specification::CURRENT_SPECIFICATION_VERSION
    s.specification_version = 3

    if Gem::Version.new(Gem::RubyGemsVersion) >= Gem::Version.new('1.2.0') then
      s.add_runtime_dependency(%q<dm-core>, [">= 0.10"])
      s.add_development_dependency(%q<rspec>, [">= 1.3"])
      s.add_development_dependency(%q<mocha>, [">= 0.9.8"])
      s.add_development_dependency(%q<yard>, [">= 0.5.3"])
    else
      s.add_dependency(%q<dm-core>, [">= 0.10"])
      s.add_dependency(%q<rspec>, [">= 1.3"])
      s.add_dependency(%q<mocha>, [">= 0.9.8"])
      s.add_dependency(%q<yard>, [">= 0.5.3"])
    end
  else
    s.add_dependency(%q<dm-core>, [">= 0.10"])
    s.add_dependency(%q<rspec>, [">= 1.3"])
    s.add_dependency(%q<mocha>, [">= 0.9.8"])
    s.add_dependency(%q<yard>, [">= 0.5.3"])
  end
end
