Feature: Mongify can be controlled using command-line options
  In order to change Mongify's default behaviour
  As a user
  I want to supply options on the command line

  Scenario: returns non-zero status on bad options
    When I run mongify --no-such-option
    Then the exit status indicates an error
    And it reports the error "Error: invalid option: --no-such-option"
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
      Usage: mongify command [database_translation.rb] [-c database.config]
			
			Commands:
			"check" or "ck"           >> Checks connection for sql and no_sql databases [configuration_file]
			"process" or "pr"         >> Takes a translation and process it to mongodb [configuration_file, translation_file]
			"translation" or "tr"     >> Outputs a translation file from a sql connection [configuration_file]
			
      Examples:
			
			mongify check -c database.config
		 	mongify translation -c datbase.config > database_translation.rb
		 	mongify process database_translation.rb -c database.config
      
      See http://github.com/anlek/mongify for more details

      Common options:
          -h, --help                       Show this message
          -v, --version                    Show version
          -c, --config FILE                Configuration File to use

      """
