#
# Mongify's core functionality
#
module Mongify
  VERSION = '0.0.2'
end

require File.join(File.dirname(__FILE__), 'core_ext', 'hash')
require File.join(File.dirname(__FILE__), 'core_ext', 'array')

require File.join(File.dirname(__FILE__), 'mongify', 'ui')
require File.join(File.dirname(__FILE__), 'mongify', 'translation')
require File.join(File.dirname(__FILE__), 'mongify', 'configuration')