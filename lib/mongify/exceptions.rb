module Mongify
  # File Not Found Exception
  class FileNotFound < RuntimeError; end
  # Raise when configuration file is missing
  class ConfigurationFileNotFound < FileNotFound; end
  # Raised when Translation file is missing
  class TranslationFileNotFound < FileNotFound; end
  
  # Basic Configuration Error Exception
  class ConfigurationError < RuntimeError; end
  # Raise when a sqlConnection is required but not given
  class SqlConnectionRequired < ConfigurationError; end
  # Raised when a noSqlConnection is required but not given
  class NoSqlConnectionRequired < ConfigurationError; end
  # Raised when a Mongify::Database::Column is expected but not given
  class DatabaseColumnExpected < ConfigurationError; end
  
  # Raised when application has no root folder set
  class RootMissing < RuntimeError; end
end