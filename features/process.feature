Feature: Processing a translation
  In order for Mongify to be useful
  As a user
  I want to be able to process a translation and move my data to mongodb!

  Scenario: Process
  Given a database exists
  And a blank mongodb
  When I run mongify process spec/files/translation.rb -c spec/files/base_configuration.rb
  Then it succeeds
  And there should be 3 users in mongodb
  And there should be 3 posts in mongodb
  And the first post's user_id should be first user
  And there should be 0 comments in mongodb
  And the first post should have 1 comment
  
  Scenario: Processing while modifying embedding parent.
  Given a database exists
  And a blank mongodb
  When I run mongify process spec/files/embedded_parent_translation.rb -c spec/files/base_configuration.rb
  Then it succeeds
  And there should be 3 users in mongodb
  And the first user's notify_by_email attribute should be true
  And the third user's notify_by_email attribute should be false
