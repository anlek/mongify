Given /^a blank mongodb$/ do
  GenerateDatabase.clear_mongodb
end

Then /^there should be (\d+) (.*) in mongodb$/ do |count, collection|
  GenerateDatabase.mongo_connection.db[collection].count.should == count.to_i
end
