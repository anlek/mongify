#
# Mongify's core functionality
#
$: << File.dirname(__FILE__)
module Mongify
  VERSION = '0.0.1'
end

require 'core_ext/hash'
require 'core_ext/array'

require 'mongify/ui'
require 'mongify/translation'
require 'mongify/configuration'

