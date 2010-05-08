module Mongify
  # File Not Found Exception
  class FileNotFound < RuntimeError; end
  class ConfigurationFileNotFound < FileNotFound; end
end