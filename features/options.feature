Feature: Mongify can be controlled using command-line options
  In order to change Mongify's default behaviour
  As a user
  I want to supply options on the command line

  Scenario: returns non-zero status on bad options
    When I run mongify --no-such-option
    Then it reports the error "Error: invalid option: --no-such-option"
    And the exit status indicates an error
    And stdout equals ""

  Scenario: display the current version number
    When I run mongify --version
    Then it succeeds
    And it reports the current version

  Scenario: display the help information
    When I run mongify --help
    Then it succeeds
    And it reports:
      """
      Usage: mongify command database.config [database_translation.rb]

      Commands:
      "check" or "ck"           >> Checks connection for sql and no_sql databases [configuration_file]
      "process" or "pr"         >> Takes a translation and process it to mongodb [configuration_file, translation_file]
      "sync" or "sy"            >> Takes a translation and process it to mongodb, only syncs (insert/update) new or updated records based on the updated_at column [configuration_file, translation_file]
      "translation" or "tr"     >> Outputs a translation file from a sql connection [configuration_file]

      Examples:

      mongify check database.config
      mongify translation datbase.config > database_translation.rb
      mongify process database.config database_translation.rb
      mongify sync database.config database_translation.rb

      See http://github.com/anlek/mongify for more details

      Common options:
          -h, --help                       Show this message
          -v, --version                    Show version
      """
