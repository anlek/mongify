Then /^the (first|second|third) ([^\s]+)'s ([^\s]+) attribute should be (.+)$/ do |collection_place, collection_name, field, value|
  DatabaseGenerator.mongo_connection.db[collection_name.pluralize].
                   find.to_a.send(collection_place.to_sym)[field].to_s.should == value.to_s
end

Then /^the (first|second|third) ([^\s]+)'s ([^\s]+) attribute should( not)? be present$/ do |collection_place, collection_name, field, negate|
  DatabaseGenerator.mongo_connection.db[collection_name.pluralize].
                    find.to_a.send(collection_place.to_sym).has_key?(field).should (negate ? be_falsey : be_truthy)
end

Then /^the (first|second|third) ([^\s]+)'s ([^\s]+)'s ([^\s]+) attribute should be (.+)$/ do |collection_place, collection_name, embedded_name, field, value|
  DatabaseGenerator.mongo_connection.db[collection_name.pluralize].
                    find.to_a.send(collection_place.to_sym)[embedded_name][field].to_s.should == value.to_s
end