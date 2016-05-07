require 'spec_helper'

describe Mongify::Database::Table do
  before(:each) do
    @table = Mongify::Database::Table.new('users')
  end

  it "should have name" do
    @table.name.should == "users"
  end
  it "should have sql_name" do
    @table.sql_name.should == "users"
  end
  it "should allow you to change table name" do
    @table.name = 'accounts'
    @table.name.should == 'accounts'
  end

  it "should be ingored" do
    table = Mongify::Database::Table.new('users', :ignore => true)
    table.should be_ignored
  end

  it "should get setup options" do
    @table = Mongify::Database::Table.new('users', :embed_in => 'accounts', :as => 'users')
    @table.options.should == {'embed_in' => 'accounts', 'as' => 'users'}
  end

  context "rename_to" do
    before(:each) do
      @table = Mongify::Database::Table.new('users', :rename_to => 'people')
    end

    it "should have new name" do
      @table.name.should == "people"
    end
    it "should have sql_name" do
      @table.sql_name.should == "users"
    end
  end

  context "column_index (find_column)" do
    it "should add column index on column creation" do
      @table.should_receive(:add_and_index_column)
      @table.column('first_name', :string)
    end
  end

  context "column" do
    it "should add to count" do
      lambda { @table.column 'name' }.should change{@table.columns.count}.by(1)
    end

    it "should work without a type" do
      col = @table.column 'name'
      col.type.should == :string
    end

    it "should work without a type with options" do
      col = @table.column 'name', :rename_to => 'first_name'
      col.type.should == :string
      col.should be_renamed
    end

    it "should be able to find" do
      @table.column 'another'
      col = @table.column 'dark'
      @table.find_column('dark').should == col
    end

    it "should be able to find (case sensitive)" do
      col = @table.column 'geoCode'
      @table.column 'filler'
      @table.find_column('geoCode').should == col
    end

    it "should be searchable with sql_name only" do
      col = @table.column 'surname', :string, :rename_to => 'last_name'
      @table.find_column('surname').should == col
    end

    it "should return nil if not found" do
      @table.column 'dark'
      @table.find_column('blue').should be_nil
    end

    it "should be able to find the key column" do
      @table.column 'name'
      col = @table.column 'id', :key, :as => :integer
      @table.column 'address'
      @table.key_column.should == col
    end
  end

  context "add_column" do
    it "should require Mongify::Database::Column" do
      expect { @table.add_column("Not a column") }.to raise_error(Mongify::DatabaseColumnExpected)
    end
    it "shold except Mongify::Database::Column as a parameter" do
      expect { @table.add_column(Mongify::Database::Column.new('test')) }.to_not raise_error
    end

    it "should add to the column count" do
      expect { @table.add_column(Mongify::Database::Column.new('test')) }.to change{@table.columns.count}.by(1)
    end

    it "should be indexed" do
      col = Mongify::Database::Column.new('test')
      @table.add_column(col)
      @table.find_column('test').should == col
    end

    context "on initialization" do
      before(:each) do
        @columns = [Mongify::Database::Column.new('test1'), Mongify::Database::Column.new('test2')]
        @table = Mongify::Database::Table.new('users', :columns => @columns)
      end
      it "should add columns" do
        @table.columns.should have(2).columns
      end
      it "should remove columns from the options" do
        @table.options.should_not have_key('columns')
      end
      it "should be indexed" do
        @table.find_column('test1').should == @columns[0]
      end
    end
  end

  context "reference_colums" do
    before(:each) do
      @col1 = Mongify::Database::Column.new('user_id', :integer, :references => 'users')
      @col2 = Mongify::Database::Column.new('post_id', :integer, :references => 'posts')
      @columns = [@col1,
                  Mongify::Database::Column.new('body'),
                  @col2]
      @table = Mongify::Database::Table.new('comments', :columns => @columns)
    end
    it "should return an array of columns" do
      @table.reference_columns.should =~ [@col1, @col2]
    end
  end

  context "dealing with embedding," do
    context "embed_on" do
      it "should return embed_on option" do
        Mongify::Database::Table.new('comments', :embed_in => 'posts', :on => 'post_id').embed_in.should == 'posts'
      end
      it "should be nil when not embedded table" do
        Mongify::Database::Table.new('users').embed_in.should be_nil
      end
    end
    context "embed_as" do
      it "should return nil if it's not an embed table" do
        Mongify::Database::Table.new('comments', :as => 'array').embed_as.should be_nil
      end
      it "should default to :array" do
        Mongify::Database::Table.new('comments', :embed_in => 'posts', :on => 'post_id').embed_as.should == 'array'
      end
      it "should allow Array as a value" do
        Mongify::Database::Table.new('comments', :embed_in => 'posts', :on => 'post_id', :as => :array).embed_as.should == 'array'
      end
      it "should allow Object as a value" do
        Mongify::Database::Table.new('comments', :embed_in => 'posts', :on => 'post_id', :as => :object).embed_as.should == 'object'
      end
      context "embedded_as_object?" do
        it "should be true" do
          Mongify::Database::Table.new('comments', :embed_in => 'posts', :on => 'post_id', :as => :object).should be_embedded_as_object
        end
        it "should be false" do
          Mongify::Database::Table.new('comments', :embed_in => 'posts', :on => 'post_id', :as => :array).should_not be_embedded_as_object
        end
      end
    end
    context "embedded?" do
      it "should be true" do
        Mongify::Database::Table.new('comments', :embed_in => 'posts', :on => 'post_id').should be_embedded
      end
      it "should be false" do
        Mongify::Database::Table.new('users').should_not be_embedded
      end
    end

    context "embed_on" do
      it "should be post_id" do
        Mongify::Database::Table.new('comments', :embed_in => 'posts', :on => 'post_id').embed_on.should == 'post_id'
      end
      it "should be nil when not embedded?" do
        Mongify::Database::Table.new('users', :on => 'test').embed_on.should be_nil
      end
      it "should calculate embed_on from embed_in" do
        Mongify::Database::Table.new('comments', :embed_in => 'posts').embed_on.should == 'post_id'
      end
    end
  end

  context "before_save" do
    before(:each) do
      @table = Mongify::Database::Table.new('users')
      @table.column "permission"
      @table.before_save do |row, _|
        row.admin = row.delete('permission').to_i > 50
      end
    end
    it "should be resetable" do
      @table.before_save do |row|
        row.test = "removed!"
      end
      @table.remove_before_save_filter!
      result = @table.send(:run_before_save, {'test'=>true})
      result.should == {'test' => true}
    end
    context "run_before_save" do
      it "should create a new DataRow" do
        row = {'first_name' => 'Bob'}
        dr = Mongify::Database::DataRow.new(row)
        Mongify::Database::DataRow.should_receive(:new).and_return(dr)
        @table.send(:run_before_save, row)
      end
      it "should preserve the pre_mongified_id even if user deletes it" do
        row = {'first_name' => 'Bob', 'pre_mongified_id' => 1}
        @table.before_save do |row, _|
          row.delete('pre_mongified_id')
        end
        @table.send(:run_before_save, row).should == row
      end
    end
    it "should work" do
      @table.translate({'permission' => 51}).should == {'admin' => true}
    end
  end
  context "before_save sending parent" do
    before(:each) do
      @parent_table = Mongify::Database::Table.new('users')
      @table = Mongify::Database::Table.new('preferences')
      @table.column "preferences"
      @table.before_save do |row, parent|
        parent.preferences = row.delete('preferences')
      end
    end
    it "should work" do
      @table.translate({'preferences' => 'yes'}, {}).should == [{}, {'preferences' => 'yes'}, {}]
    end
    it "should return blank hash if parent is unchanged" do
      @table.remove_before_save_filter!
      @table.translate({'preferences' => "true"}, {}).should == [{'preferences' => "true"}, {}, {}]
    end
    it 'should return a hash containing the keys that have been deleted on the parent row' do
      @parent_table.column('field_1')
      @parent_table.column('field_2')
      @table.before_save do |_, parent|
        parent.delete('field_1')
      end
      @table.translate({'preferences' => 'true'},{'field_1' => 'a', 'field_2' => 'b'}).should ==
          [{'preferences' => 'true'}, {'field_2' => 'b'}, {'field_1' => '1'}]
    end

  end



  context "polymorphic" do
    before(:each) do
      @table = Mongify::Database::Table.new('comments', :polymorphic => :commentable)
    end
    it "should be true" do
      @table.should be_polymorphic
    end
    it "should be false" do
      Mongify::Database::Table.new('users').should_not be_polymorphic
    end
    it "should return 'commentable'" do
      @table.polymorphic_as.should == 'commentable'
    end

    context "embed" do
      before(:each) do
        @table = Mongify::Database::Table.new('comments', :polymorphic => :commentable, :embed_in => true)
      end
      it "should be embedded" do
        @table.should be_embedded
      end

    end
  end

  context "translate" do
    before(:each) do
      @column1 = double(:translate => {'first_name' => 'Timmy'}, :name => 'first_name')
      @column2 = double(:translate => {'last_name' => 'Zuza'}, :name => 'last_name')
      @table.stub(:find_column).with(anything).and_return(nil)
      @table.stub(:find_column).with('first_name').and_return(@column1)
      @table.stub(:find_column).with('last_name').and_return(@column2)
    end
    it "should return a correct hash" do
      @table.translate({'first_name' => 'Timmy', 'last_name' => 'Zuza'}).should == {'first_name' => 'Timmy', 'last_name' => 'Zuza'}
    end
    it "should send translate to both columns with the given value" do
      @column1.should_receive(:translate).with('Timmy').and_return({'first_name' => 'Timmy'})
      @column2.should_receive(:translate).with('Zuza').and_return({'last_name' => 'Zuza'})
      @table.translate({'first_name' => 'Timmy', 'last_name' => 'Zuza'})
    end

    it "should not return any value if column doesn't exist in the translation" do
      @table.translate({'age' => 18}).should == {}
    end
  end
end
