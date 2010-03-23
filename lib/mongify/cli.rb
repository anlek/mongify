require 'optparse'

require 'mongify'
require 'mongify/cli/options'
require 'mongify/cli/execute'

module Mongify
  class CLI
    attr_reader :args
    attr_accessor :command, :file_path
    include Execute, Options
    
    def initialize(arguments, stdin=$stdin, stdout=$stdout)
      @args = arguments.dup
      Mongify::Configuration.in_stream = stdin
      Mongify::Configuration.out_stream = stdout
      parse_options!
    end
  end
end