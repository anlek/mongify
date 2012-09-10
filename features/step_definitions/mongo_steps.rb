Given /^a blank mongodb$/ do
  DatabaseGenerator.clear_mongodb
end

Then /^there should be (\d+) (.*) in mongodb$/ do |count, collection|
  DatabaseGenerator.mongo_connection.db[collection].count.should == count.to_i
end

Then /^the (first|second|third) (.+)'s (.+) should be (first|second|thrid) (.+)$/ do |collection_place, collection, field, target_place, target|
  DatabaseGenerator.mongo_connection.db[collection.pluralize].find.to_a.send(collection_place.to_sym)[field].should == DatabaseGenerator.mongo_connection.db[target.pluralize].find.to_a.send(target_place)['_id']
end

Then /^the (.+) with (.+) "(.+)" should have (\d+) (.+)$/ do |collection, find_by, find_value, count, target|
  DatabaseGenerator.mongo_connection.find_one(collection.pluralize, { find_by => find_value })[target.pluralize].count.should == count.to_i
end