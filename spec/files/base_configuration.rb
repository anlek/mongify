sql_connection do
  adapter     'sqlite3'
  database    'spec/tmp/test.sqlite'
end

mongodb_connection do
  host          '127.0.0.1'
  database      'mongify_test'
end