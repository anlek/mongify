require 'spec_helper'

describe Mongify::Database::Column do
  before(:each) do
    @column = Mongify::Database::Column.new('first_name')
  end

  it "should have name" do
    @column.name.should == 'first_name'
  end
  it "should have a sql_name" do
    @column.sql_name.should == 'first_name'
  end

  it "should allow you to omit the type while giving options" do
    @column = Mongify::Database::Column.new('account_id', :references => 'accounts')
    @column.options.should == {'references' => 'accounts'}
  end

  it "should get setup options" do
    @column = Mongify::Database::Column.new('account_id', :integer, :references => 'accounts')
    @column.options.should == {'references' => 'accounts'}
  end

  it "should force type to string if nil" do
    @column = Mongify::Database::Column.new('first_name', nil)
    @column.type.should == :string
  end

  context "auto_detect!" do
    it "should not auto detect automatically" do
      Mongify::Database::Column.should_receive(:auto_detect).never
      @column = Mongify::Database::Column.new('id', :integer)
      @column.should_not be_key
    end

    it "should auto_detect when option is passed in" do
      @column = Mongify::Database::Column.new('id', :integer, :auto_detect => true)
      @column.should be_key
    end

    context "id column" do
      before(:each) do
        @col = double(:sql_name => 'id')
      end
      it "should detect column with type :integer as a :key column" do
        @col.stub(:type).and_return(:integer)
        @col.should_receive('type=').with(:key)
        @col.should_receive('as=').with(:integer)
        Mongify::Database::Column.auto_detect(@col)
      end
      it "should detected as a :key even if type is :string" do
        @column = Mongify::Database::Column.new('id', :string, :auto_detect => true)
        @column.should be_key
        @column.as.should == :string
      end

      it "should detect as a :key with as == integer " do
        @column = Mongify::Database::Column.new('id', :integer, :auto_detect => true)
        @column.should be_key
        @column.as.should == :integer
      end

    end
    context "references" do
      before(:each) do
        @col = double(:sql_name => 'post_id', :type => :integer, :referenced? => false)
      end
      it "should detect column references" do
        @col.should_receive('references=').with('posts')
        Mongify::Database::Column.auto_detect(@col)
      end
      it "should not detect column references if it's already referenced" do
        @col.stub(:referenced?).and_return(true)
        @col.should_receive('references=').never
        Mongify::Database::Column.auto_detect(@col)
      end
      it "should detect column references even if column type is not :integer" do
        @col.stub(:type).and_return(:string)
        @col.should_receive('references=').once
        Mongify::Database::Column.auto_detect(@col)
      end
    end
  end

  context "key?" do
    it "should be true" do
      @column = Mongify::Database::Column.new('id', :key)
      @column.should be_a_key
    end

    it "should be true" do
      @column = Mongify::Database::Column.new('first_name', :string)
      @column.should_not be_a_key
    end
  end

  context "rename_to" do
    before(:each) do
      @column = Mongify::Database::Column.new('surname', :string, :rename_to => 'last_name')
    end
    it "should have the right sql_name" do
      @column.sql_name.should == 'surname'
    end
    it "should have the right name" do
      @column.name.should == 'last_name'
    end
    it "should translate to new name" do
      @column.translate('value').should == {'last_name' => 'value'}
    end

    it "should rename this" do
      @column = Mongify::Database::Column.new("geoCode_longitude", :string, :rename_to => 'longitude')
      @column.translate(42.2222).should == {'longitude' => '42.2222'}
    end

    it "should be renamed" do
      @column.should be_renamed
    end
    it "should be not renamed" do
      col = Mongify::Database::Column.new('surname', :string)
      col.should_not be_renamed
    end
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

  context "as" do
    subject {Mongify::Database::Column.new('total', :decimal)}
    it "should default to string" do
      subject.as.should == :string
    end
    it "should allow it to be set to integer" do
      subject.as = :integer
      subject.should be_as_integer
    end
    it "should not allow other values" do
      subject.as = "zuza"
      subject.as.should == :string
    end
    it "should not allow other values even as sym" do
      subject.as = :zuza
      subject.as.should == :string
    end
    it "should convert to symble" do
      subject.as = 'integer'
      subject.as.should == :integer
    end
  end

  context "scale" do
    subject {Mongify::Database::Column.new('total', :decimal, :as => 'integer')}
    it "should be defaulted to 0" do
      subject.scale.should be_zero
    end
    it "should let you set the scale" do
      subject.scale = 3
      subject.scale.should == 3
    end
    it "should return 0 on invalid input" do
      subject.scale = 'zuza'
      subject.scale.should be_zero
    end
  end

  context :to_print do
    before(:each) do
      @column = Mongify::Database::Column.new('first_name', :string)
    end
    it "should output column name and type" do
      @column.to_print.should == %Q[column "first_name", :string]
    end
    it "should output the same when called .to_s" do
      @column.to_s.should == %Q[column "first_name", :string]
    end
    it "should detect references" do
      @column = Mongify::Database::Column.new('user_id', :integer, :auto_detect => true)
      @column.to_print.should == %Q[column "user_id", :integer, :references => "users"]
    end

    it "should print :key with :as" do
      @column.as = :integer
      @column.type = :key
      @column.to_print.should == %q{column "first_name", :key, :as => :integer}
    end
  end

  context :referenced? do
    it "should be true" do
      @column = Mongify::Database::Column.new('user_id', :integer, :references => 'users')
      @column.should be_a_referenced
    end
  end

  context :translate do
    it "should return a hash with the new translation" do
      @column = Mongify::Database::Column.new('first_name', :string)
      @column.translate('bob').should == {'first_name' => 'bob'}
    end
    it "should ignore an ignored column" do
      @column = Mongify::Database::Column.new('first_name', :string, :ignore => true)
      @column.should be_ignored
      @column.translate('bob').should == {}
    end

    it "should return pre_mongified_id when type is a key" do
      @column = Mongify::Database::Column.new('id', :key)
      @column.translate(123123).should == {"pre_mongified_id" => 123123}
    end
    it "should return an integer for pre_mongified_id (by default)" do
      @column = Mongify::Database::Column.new('id', :key)
      result = @column.translate('123123')
      result.should == {"pre_mongified_id" => 123123}
      result['pre_mongified_id'].should be_a_kind_of Integer

    end
    it "should return a string for pre_mongified_id when :as => :string is provided" do
      @column = Mongify::Database::Column.new('id', :key, :as => :string)
      result = @column.translate('p123')
      result.should == {"pre_mongified_id" => 'p123'}
      result['pre_mongified_id'].should be_a_kind_of String
    end
  end
  context :type_cast do
    it "should return value if unknown type" do
      @column = Mongify::Database::Column.new('first_name', :car)
      @column.send(:type_cast, 'bob').should == 'bob'
    end
    context "datetime" do
      before(:each) do
        @column = Mongify::Database::Column.new('created_at', :datetime)
      end
      it "should return a datetime format" do
        @column.send(:type_cast, '2011-01-14 21:23:39').should == Time.utc(2011, 01, 14, 21, 23,39)
      end
      it "should return nil if input is nil" do
        @column.send(:type_cast, nil).should == nil
      end
    end
    context :integer do
      before(:each) do
        @column = Mongify::Database::Column.new('account_id', :integer)
      end
      it "should return 10" do
        @column.send(:type_cast, "10").should == 10
      end
      it "should return 0 when string given" do
        @column.send(:type_cast, "bob").should == 0
      end
    end
    context :text do
      it "should return a string" do
        @column = Mongify::Database::Column.new('body', :text)
        @column.send(:type_cast, "Something of a body").should == "Something of a body"
      end
    end
    context :float do
      before(:each) do
        @column = Mongify::Database::Column.new('price', :float)
      end
      it "should convert numbers to floats" do
        @column.send(:type_cast, 101.43).should == 101.43
      end
      it "should convert integers to floats" do
        @column.send(:type_cast, 101).should == 101.0
      end
      it "should convert strings to 0.0" do
        @column.send(:type_cast, 'zuza').should == 0.0
      end
    end
    context :decimal do
      before(:each) do
        @column = Mongify::Database::Column.new('price', :decimal)
      end
      it "should convert numbers to decimal string" do
        @column.send(:type_cast, 101.43).should == "101.43"
      end
      it "should convert integers to decimal string" do
        @column.send(:type_cast, 101).should == "101.0"
      end
      it "should convert strings to 0.0 (string)" do
        @column.send(:type_cast, 'zuza').should == "0.0"
      end
      it "should return a string value" do
        @column.send(:type_cast, 101.43).should be_a_kind_of String
      end

      context :integer do
        before(:each) do
          @column = Mongify::Database::Column.new('price', :decimal, :as => :integer)
          @value = 101.123455
        end
        it "should be as_integer" do
          @column.should be_as_integer
        end
        it "should convert number to integer" do
          @column.send(:type_cast, @value).should == 101
        end
        it "should let you specify scale" do
          @column.scale = 3
          @column.send(:type_cast, @value).should == 101123
        end
        it "should round correctly to specified scale" do
          @column.scale = 4
          @column.send(:type_cast, @value).should == 1011235
        end
        it "should return an integer value" do
          @column.scale = 3
          @column.send(:type_cast, @value).should be_an_integer
        end
      end
    end
    context :timestamp do
      before(:each) do
        @column = Mongify::Database::Column.new('created_at', :timestamp)
      end
      it "should return a datetime format" do
        @column.send(:type_cast, '2011-01-14 21:23:39').should == Time.utc(2011, 01, 14, 21, 23,39)
      end
      it "should return nil if input is nil" do
        @column.send(:type_cast, nil).should == nil
      end
    end
    context :time do
      before(:each) do
        @column = Mongify::Database::Column.new('created_at', :time)
      end
      it "should return a time format" do
        @column.send(:type_cast, '21:23:39').should == Time.utc(2000, 01, 01, 21, 23,39)
      end
      it "should return nil if input is nil" do
        @column.send(:type_cast, nil).should == nil
      end
    end
    context :date do
      before(:each) do
        @column = Mongify::Database::Column.new('created_at', :date)
      end
      it "should return a time format" do
        @column.send(:type_cast, '2011-01-14').should == Time.utc(2011, 01, 14)
      end
      it "should return nil if input is nil" do
        @column.send(:type_cast, nil).should == nil
      end
    end
    context :binary do
      it "should return a string" do
        @column = Mongify::Database::Column.new('body', :binary)
        @column.send(:type_cast, "Something of a body").should == "Something of a body"
      end
    end
    context :string do
      it "should return a string" do
        @column = Mongify::Database::Column.new('body', :string)
        @column.send(:type_cast, 42.222).should == "42.222"
      end
    end
    context :boolean do
      before(:each) do
        @column = Mongify::Database::Column.new('email_me', :boolean)
      end
      it "should be true when true" do
        result = true
        @column.send(:type_cast, "true").should == result
        @column.send(:type_cast, "1").should == result
        @column.send(:type_cast, "T").should == result
      end
      it "should be false when false" do
        result = false
        @column.send(:type_cast, "false").should == result
        @column.send(:type_cast, "0").should == result
        @column.send(:type_cast, "F").should == result
      end
      it "should be nil if nil or blank" do
        result = nil
        @column.send(:type_cast, nil).should == result
        @column.send(:type_cast, "").should == result
      end

    end
  end
end
