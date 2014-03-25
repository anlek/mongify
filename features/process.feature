Feature: Processing a translation
  In order for Mongify to be useful
  As a user
  I want to be able to process a translation and move my data to mongodb!

  Scenario: Process
  Given a database exists
  And a blank mongodb
  When I run mongify process spec/files/base_configuration.rb spec/files/translation.rb
  Then it succeeds
  And there should be 3 users in mongodb
  And there should be 3 posts in mongodb
  And the "First Post" author should be Timmy
  And there should be 0 comments in mongodb
  And the post with title "First Post" should have 1 comment
  And the post with title "Second Post" should have 2 comments

  Scenario: Processing while modifying embedding parent.
  Given a database exists
  And a blank mongodb
  When I run mongify process spec/files/base_configuration.rb spec/files/embedded_parent_translation.rb
  Then it succeeds
  And there should be 3 users in mongodb
  And the first user's notify_by_email attribute should be true
  And the third user's notify_by_email attribute should be false

  Scenario: Processing while deleting fields from embedding parent
  Given a database exists
  And a blank mongodb
  When I run mongify process spec/files/base_configuration.rb spec/files/deleting_fields_from_embedding_parent_translation.rb
  Then it succeeds
  And there should be 3 teams in mongodb
  And the first team's phone attribute should not be present
  And the third team's coach's phone attribute should be +1112223334
