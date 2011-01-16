Given /^a blank mongodb$/ do
  GenerateDatabase.clear_mongodb
end

Then /^there should be (\d+) (.*) in mongodb$/ do |count, collection|
  GenerateDatabase.mongo_connection.db[collection].count.should == count.to_i
end

Then /^(first|sencond|third) (.+)'s (.+) should be (first|second|thrid) (.+)$/ do |collection_place, collection, field, target_place, target|
  GenerateDatabase.mongo_connection.db[collection.pluralize].find.to_a.send(collection_place.to_sym)[field].should == GenerateDatabase.mongo_connection.db[target.pluralize].find.to_a.send(target_place)['_id']
end
