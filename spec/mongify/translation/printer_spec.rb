require 'spec_helper'

describe Mongify::Translation do
  context "print" do
    before(:each) do
      cols = [Mongify::Database::Column.new('first_name', :string),
              Mongify::Database::Column.new('age', :integer),
              Mongify::Database::Column.new('bio', :text)]
      @table = Mongify::Database::Table.new("users", :columns => cols)
      @translation = Mongify::Translation.new()
      @translation.add_table(@table)
      @table2 = Mongify::Database::Table.new('posts')
      @table2.column('id', :key)
      @translation.add_table(@table2)
    end

    subject{@translation}

    it "should output correctly" do
      subject.print.should == <<-EOF
table "users" do
\tcolumn "first_name", :string
\tcolumn "age", :integer
\tcolumn "bio", :text
end

table "posts" do
\tcolumn "id", :key
end

EOF
    end
  end
end
