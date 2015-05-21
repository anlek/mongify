Feature: Database Translation Output
  In order to translate sql database to a no-sql database
  As a developer / database admin
  Needs to be able to generate a translation file

  Scenario: Translation Output request
    Given a database exists
    When I run mongify translation spec/files/base_configuration.rb
    Then it succeeds
    And it should print out the database schema
