module Mongify
  # File Not Found Exception
  class FileNotFound < RuntimeError; end
  class ConfigurationFileNotFound < FileNotFound; end
  
  class ConfigurationError < RuntimeError; end
  class SqlConnectionRequired < ConfigurationError; end
  class DatabaseColumnExpected < ConfigurationError; end
  
  class RootMissing < RuntimeError; end
end