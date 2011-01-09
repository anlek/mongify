#
# Mongify's core functionality
#
require 'core_ext/hash'
require 'core_ext/array'

require 'mongify/ui'
require 'mongify/exceptions'
require 'mongify/translation'
require 'mongify/configuration'
require 'mongify/database'

module Mongify
  class << self
    def root=(value)
      @root = value
    end
    def root
      raise RootMissing, "Root not configured" if @root.nil?
      @root
    end
  end
end