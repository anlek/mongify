require 'spec_helper'

describe Mongify::Database::Column do
  before(:each) do
    @column = Mongify::Database::Column.new('first_name')
  end
  
  it "should have name" do
    @column.name.should == 'first_name'
  end
  
  it "should get setup options" do
    @column = Mongify::Database::Column.new('account_id', :integer, :references => 'accounts')
    @column.options.should == {'references' => 'accounts'}
  end
  
  it "should force type to string if nil" do
    @column = Mongify::Database::Column.new('first_name', nil)
    @column.type.should == :string
  end
  
  context "options" do
    it "should allow to be set by name" do
      @column = Mongify::Database::Column.new('first_name')
      @column.references = "users"
      @column.references.should == "users"
    end

    it "should not allow to be set unless they're in the AVAILABLE_OPTIONS" do
      @column = Mongify::Database::Column.new('first_name')
      lambda { @column.unknown = "users" }.should raise_error(NoMethodError)
    end
  end  
  
  context "auto_detect" do
    context "id" do
      it "should type to key" do
        @column = Mongify::Database::Column.new('id', :integer)
        @column.type.should == :key
      end
      it "should not set type to key if original type is not integer" do
        @column = Mongify::Database::Column.new('id', :string)
        @column.type.should == :string
      end
    end
    
    it "should detect references" do
      @column = Mongify::Database::Column.new('user_id', :integer)
      @column.references.should == "users"
    end
  end
  
  context :to_print do
    before(:each) do
      @column = Mongify::Database::Column.new('first_name', :string)
    end
    it "should output column name and type" do
      @column.to_print.should == %Q[column "first_name", :string]
    end
    it "should detect references" do
      @column = Mongify::Database::Column.new('user_id', :integer)
      @column.to_print.should == %Q[column "user_id", :integer, :references => "users"]
    end
    it "should output nil options" do
      @column.default = nil
      @column.to_print.should == %Q[column "first_name", :string]
    end
  end
end
