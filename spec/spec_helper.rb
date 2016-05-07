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

require 'rspec/core'
require 'rspec/collection_matchers'

Dir['./spec/support/**/*.rb'].map {|f| require f}

::CONNECTION_CONFIG = ConfigReader.new(File.dirname(File.expand_path(__FILE__)) + '/support/database.yml')

Mongify.root = File.dirname(File.dirname(__FILE__))

::DATABASE_PRINT = File.read(File.dirname(File.expand_path(__FILE__)) + '/support/database_output.txt')

# redirect deprecation warnings of rspec to a file
RSpec.configure do |rspec|
  rspec.deprecation_stream = 'log/deprecations.log'
end
# mute the deprecation message from I18n
I18n.enforce_available_locales = false