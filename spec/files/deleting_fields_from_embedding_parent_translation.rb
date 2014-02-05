table 'teams' do
  column 'id', :key
  column 'name', :string
  column 'phone', :string
  column 'created_at', :datetime
  column 'updated_at', :datetime
end

table 'coaches', :embed_in => 'teams', :as => 'object', :rename_to => 'coach' do
  column 'id', :key
  column 'team_id', :integer, :references => "teams"
  column 'first_name', :string
  column 'last_name', :string
  column 'created_at', :datetime
  column 'updated_at', :datetime
  before_save do |row, parent_row|
    row.write_attribute('phone',parent_row.delete('phone'))
  end
end