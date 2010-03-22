require 'spec'
require File.dirname(__FILE__) + '/../lib/mongify'
 
Spec::Runner.configure do |config|
  config.mock_with :mocha
end