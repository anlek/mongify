require 'rubygems'
require 'yaml'
$:.unshift File.join(File.dirname(__FILE__), '..', 'lib')
require 'mongify'
require 'mongify/cli'

begin
  require 'bundler'
  Bundler.setup
rescue LoadError
  puts "Need to install bundler 1.0. 'gem install bundler'"
end

begin
  require 'spec/expectations'
rescue LoadError
  gem 'rspec'
  require 'spec/expectations'
end

#Used to setup testing databases
require 'support/config_reader'
::CONNECTION_CONFIG = ConfigReader.new(File.dirname(File.expand_path(__FILE__)) + '/support/database.yml')

