Then /^the (first|second|third) (.+)'s (.+) attribute should be (.+)$/ do |collection_place, collection_name, field, value|
  DatabaseGenerator.mongo_connection.db[collection_name.pluralize].
                   find.to_a.send(collection_place.to_sym)[field].to_s.should == value.to_s
end