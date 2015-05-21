module Mongify
  # Base Mongify Error
  class MongifyError < RuntimeError; end

  # Not Implemented Error from Mongify
  class NotImplementedMongifyError < MongifyError; end

  # File Not Found Exception
  class FileNotFound < MongifyError; end
  # Raise when configuration file is missing
  class ConfigurationFileNotFound < FileNotFound; end
  # Raised when Translation file is missing
  class TranslationFileNotFound < FileNotFound; end

  # Basic Configuration Error Exception
  class ConfigurationError < MongifyError; end
  # Raise when a sqlConnection is required but not given
  class SqlConnectionRequired < ConfigurationError; end
  # Raised when a SqlConfiguration is invalid?
  class SqlConnectionInvalid < ConfigurationError; end
  # Raised when a noSqlConnection is required but not given
  class NoSqlConnectionRequired < ConfigurationError; end
  # Raised when a NoSqlConfiguration is invalid?
  class NoSqlConnectionInvalid < ConfigurationError; end

  # Raised when a Mongify::Database::Column is expected but not given
  class DatabaseColumnExpected < ConfigurationError; end

  # Raised when application has no root folder set
  class RootMissing < MongifyError; end

  # Raised when an invalid option is passed via CLI
  class InvalidOption < MongifyError; end
end