require 'spec_helper'

describe Mongify::Translation do
  context "print" do
    before(:each) do
      cols = [Mongify::Database::Column.new('first_name', :string),
              Mongify::Database::Column.new('age', :integer, :default => 18),
              Mongify::Database::Column.new('bio', :text)]
      @table = Mongify::Database::Table.new("users", :columns => cols)
      @translation = Mongify::Translation.new()
      @translation.add_table(@table)
      @table2 = Mongify::Database::Table.new('posts')
      @table2.column('id', :integer)
      @translation.add_table(@table2)
    end
    
    subject{@translation}

    it "should output correctly" do
      subject.print.should == %Q{table "users" do
  column "first_name", :string
  column "age", :integer, "default"=>18
  column "bio", :text
end

table "posts" do
  column "id", :integer
end

}
    end
  end
end
