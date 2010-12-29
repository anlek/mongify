module Mongify
  # File Not Found Exception
  class FileNotFound < RuntimeError; end
  class ConfigurationFileNotFound < FileNotFound; end
  
  class SqlConnectionRequired < RuntimeError; end
  class DatabaseColumnExpected < RuntimeError; end
end