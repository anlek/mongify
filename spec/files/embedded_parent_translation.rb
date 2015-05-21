table "users" do
  column "id", :key
  column "first_name", :string
  column "last_name", :string
  column "created_at", :datetime
  column "updated_at", :datetime
end

table "preferences", :embed_in => :users, :as => :array do
	column "id", :key
	column "user_id", :integer, :references => "users"
	column "notify_by_email", :boolean
	column "created_at", :datetime, :ignore => true
	column "updated_at", :datetime, :ignore => true

	before_save do |row, parent|
	  parent.notify_by_email = row.delete('notify_by_email')
	end
end


