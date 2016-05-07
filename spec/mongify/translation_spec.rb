require 'spec_helper'

describe Mongify::Translation do
  before(:all) do
    @file_path = File.expand_path(File.dirname(__FILE__) + '/../files/translation.rb')
    @translation = Mongify::Translation.parse(@file_path)
  end

  context "self.load" do
    it "should require connection" do
      lambda {Mongify::Translation.load}.should raise_error(ArgumentError)
    end
    it "should only take sql_connections" do
      lambda {Mongify::Translation.load("Something else")}.should raise_error(Mongify::SqlConnectionRequired)
    end
    context "translation" do
      before(:each) do
        @connection = Mongify::Database::SqlConnection.new
        @connection.stub(:has_connection?).and_return(true)
        @connection.stub(:valid?).and_return(true)
        @connection.stub(:tables).and_return(['users'])
        col = double(:name => 'first_name', :type => 'string', :default => nil)
        @connection.stub(:columns_for).with('users').and_return([col])
      end
      it "should return a translation" do
        Mongify::Translation.load(@connection).should be_a(Mongify::Translation)
      end
      it "should have 1 table" do
        Mongify::Translation.load(@connection).tables.should have(1).table
      end
      it "should have 1 column for the table" do
        Mongify::Translation.load(@connection).tables.first.columns.should have(1).column
      end
    end
  end

  context "parsed content" do
    context "tables" do
      it "should have 4 tables" do
        @translation.should have(4).tables
      end

      it "should setup 'comments'" do
        table = @translation.tables.find{|t| t.name == 'comments'}
        table.should_not be_nil
        table.options.keys.should_not be_empty
      end
    end
  end

  context "find" do
    before(:each) do
      @user_table = double(:name => 'users')
      @translation.stub(:all_tables).and_return([double(:name => 'comments'),
                                                 @user_table,
                                                 double(:name => 'posts')])
    end
    it "should work" do

      @translation.find('users').should == @user_table
    end
    it "should return nil if nothing is found" do
      @translation.find('apples').should be_nil
    end
  end

  context "tables reference" do
    before(:each) do
      @copy_table = double(:name => 'users', :ignored? => false, :embedded? => false, :polymorphic? => false)
      @embed_table = double(:name => 'comments', :ignored? => false, :embedded? => true, :polymorphic? => false)
      @ignored_table = double(:name => 'apples', :ignored? => true, :embedded? => false, :polymorphic? => false)
      @polymorphic_table = double(:name => 'comments', :ignored? => false, :embedded? => false, :polymorphic? => true)
      @translation = Mongify::Translation.new()
      @all_tables = [@copy_table, @embed_table, @ignored_table, @polymorphic_table]
      @translation.stub(:all_tables).and_return(@all_tables)
    end
    context "tables" do
      it "should not show ignored" do
        @translation.tables.count == @all_tables.count - 1
      end
    end
    context "copy_tables" do
      it "should return tables that are not embeded" do
        @translation.copy_tables.should == [@copy_table]
      end
    end
    context "embed_tables" do
      it "should return only tables for embedding" do
        @translation.embed_tables.should == [@embed_table]
      end
    end
    it "should return only polymorphic tables" do
      @translation.polymorphic_tables.should == [@polymorphic_table]
    end
  end

  context "add_table" do
    before(:each) do
      @table = Mongify::Database::Table.new("users")
      @translation = Mongify::Translation.new()
    end
    it "should work" do
      lambda { @translation.add_table(@table) }.should change{@translation.tables.count}.by(1)
    end
  end
end
