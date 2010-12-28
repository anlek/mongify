sql_config do |s|
  s.adapter =  :sqlite3
  s.database = 'spec/files/sample_db.sqlite'
end

mongodb_config do |m|
  m.host =        '127.0.0.1'
  m.collection =  'my_collection'
end