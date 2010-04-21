table "accounts"

table "users" 

table "user_accounts", :embed_in => :users, :on => :user_id do |t|
  t.column  "account_id", :references => :account
end