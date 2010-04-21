sql_config do |s|
  s.adaptor   :mysql
  s.host      "localhost"
  s.database  "my_database"
end

mongodb_config do |m|
  m.host       '127.0.0.1'
  m.collection 'my_collection'
end