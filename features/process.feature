Feature: Processing a translation
  In order for Mongify to be useful
  As a user
  I want to be able to process a translation and move my data to mongodb!

	@wip
	Scenario: Process
	Given a database exists
	And a blank mongodb
  When I run mongify process spec/files/simple_translation.rb -c spec/files/base_configuration.rb
  Then it succeeds
	And there should be 3 users in mongodb
	And there should be 3 posts in mongodb
	And first post's owner_id should be first user
	And there should be 3 comments in mongodb
	
	
	

  
