$:.unshift 'lib'

require 'rubygems'
require 'tempfile'
require 'fileutils'
require 'mongify/cli/application'
require 'mongify'
require 'spec/support/generate_database'
require 'spec/support/config_reader'

::CONNECTION_CONFIG = ConfigReader.new(File.dirname(File.dirname(File.dirname(File.expand_path(__FILE__)))) + '/spec/support/database.yml')
::DATABASE_PRINT = File.read(File.dirname(File.dirname(File.dirname(File.expand_path(__FILE__)))) + '/spec/support/database_output.txt')

# Used to run mongify command
module MongifyWorld
  # Executes command and tracks results
  def run(cmd)
    stderr_file = Tempfile.new('mongify-world')
    stderr_file.close
    @last_stdout = `#{cmd} 2> #{stderr_file.path}`
    @last_exit_status = $?.exitstatus
    @last_stderr = IO.read(stderr_file.path)
  end
   
  # Executes mongify command with arguments
  def mongify(args)
    run("ruby -Ilib -rubygems bin/mongify #{args}")
  end
end

World(MongifyWorld)
