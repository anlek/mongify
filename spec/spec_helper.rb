require 'rubygems'

begin
  require 'bundler'
  Bundler.setup  
rescue LoadError
  puts "Need to install bundler 1.0. 'gem install bundler --pre'"
end

begin
  require 'spec/expectations'
rescue LoadError
  gem 'rspec'
  require 'spec/expectations'
end