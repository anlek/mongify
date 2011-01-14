table "users" do
	column "id", :key
	column "first_name", :string
	column "last_name", :string
	column "created_at", :datetime
	column "updated_at", :datetime
end

table "posts" do
	column "id", :key
	column "title", :string
	column "owner_id", :integer, :references => :users
	column "body", :text
	column "published_at", :datetime
	column "created_at", :datetime
	column "updated_at", :datetime
end

table "comments", :embed_in => :posts, :on => :post_id do
	column "id", :key
	column "body", :text
	column "post_id", :integer, :referneces => :posts
	column "user_id", :integer, :references => :users
	column "created_at", :datetime
	column "updated_at", :datetime
end