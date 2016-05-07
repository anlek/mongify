require 'spec_helper'

describe Mongify::Database::NoSqlConnection do
  before(:each) do
    @host = '127.0.0.1'
    @database = 'mongify_test'
    @mongodb_connection = Mongify::Database::NoSqlConnection.new
  end

  context "valid?" do
    it "should be true" do
      Mongify::Database::NoSqlConnection.new(:host => 'localhost', :database => 'blue').should be_valid
    end
    it "should be false without any params" do
      Mongify::Database::NoSqlConnection.new().should_not be_valid
    end

    it "should be false without database" do
      Mongify::Database::NoSqlConnection.new(:host => 'localhost').should_not be_valid
    end

    it "should be false without host" do
      Mongify::Database::NoSqlConnection.new(:database => 'blue').should_not be_valid
    end
  end

  it "should rename mongo to mongodb for adapter" do
    Mongify::Database::NoSqlConnection.new(:host => 'localhost', :database => 'blue', :adapter => 'mongo').adapter.should == 'mongodb'
  end

  context "connection string" do
    before(:each) do
      @mongodb_connection.host @host
      @mongodb_connection.database @database
    end

    context "without username or password" do
      it "should render correctly" do
        @mongodb_connection.connection_string.should == "mongodb://#{@host}"
      end

      it "should include port" do
        @mongodb_connection.port 10101
        @mongodb_connection.connection_string.should == "mongodb://#{@host}:10101"
      end
    end
  end

  context "connection" do
    before(:each) do
      @mock_connection = double(:connected? => true)
      Mongo::Connection.stub(:new).and_return(@mock_connection)
    end

    it "should only create a connection once" do
      Mongo::Connection.should_receive(:new).once
      @mongodb_connection.connection
      @mongodb_connection.connection
    end

    it "should add_auth if username && password is present" do
      @mock_connection.should_receive(:add_auth)
      @mongodb_connection.username "bob"
      @mongodb_connection.password "secret"
      @mongodb_connection.connection
    end

  end


  context "database action:" do
    before(:each) do
       @collection = double
       @db = double
       @db.stub(:[]).with('users').and_return(@collection)
       @mongodb_connection.stub(:db).and_return(@db)
    end
    context "insert_into" do
      it "should insert into a table using the mongo driver" do
        @collection.should_receive(:insert).with({'first_name' => 'bob'})
        @mongodb_connection.insert_into('users', {'first_name' => 'bob'})
      end
    end

    context "get_id_using_pre_mongified_id" do
      it "should return new id" do
        @collection.should_receive(:find_one).with({"pre_mongified_id"=>1}).and_return({'_id' => '123'})
        @mongodb_connection.get_id_using_pre_mongified_id('users', 1).should == '123'
      end
      it "should return nil if nothing is found" do
        @collection.should_receive(:find_one).with({"pre_mongified_id"=>1}).and_return(nil)
        @mongodb_connection.get_id_using_pre_mongified_id('users', 1).should == nil
      end
    end

    context "select_rows" do
      it "should return all records" do
        @collection.should_receive(:find).with(no_args).and_return([])
        @mongodb_connection.select_rows('users')
      end
    end

    context "select_by_query" do
      it "should return some records according to a query" do
        query = {"dummy" => true}
        @collection.should_receive(:find).with(query).and_return([])
        @mongodb_connection.select_by_query('users', query)
      end
    end

    context "update" do
      it "should update the record" do
        attributes = {'post_id' => 123}
        @collection.should_receive(:update).with({"_id" => 1}, attributes)
        @mongodb_connection.update('users', 1, attributes)
      end
    end

    context "upsert" do
      it "should update the record if its pre_mongified_id exists" do
        attributes = {'pre_mongified_id' => 1, 'post_id' => 123}
        id = 10
        duplicate = double
        duplicate.stub(:[]).with(:_id).and_return(id)
        @mongodb_connection.stub(:find_one).with('users', {"pre_mongified_id" => 1}).and_return(duplicate)
        @mongodb_connection.should_receive(:find_one).with('users', {"pre_mongified_id" => 1})
        @mongodb_connection.should_receive(:update).with('users', id, attributes)
        @mongodb_connection.upsert('users', attributes)
      end

      it "should insert a new record if no record having the same pre_mongified_id exists" do
        attributes = {'pre_mongified_id' => 1, 'post_id' => 123}
        @mongodb_connection.should_receive(:find_one).with('users', {"pre_mongified_id" => 1})
        @mongodb_connection.should_receive(:insert_into).with('users', attributes)
        @mongodb_connection.upsert('users', attributes)
      end

      it "should delegate the upsert to the save method of Mongo if no pre_mongified_id to match with the _id" do
        attributes = {'post_id' => 123}
        @collection.should_receive(:save).with(attributes)
        @mongodb_connection.upsert('users', attributes)
      end
    end

    context "find_one" do
      it "should call find_one on collection" do
        query= {'pre_mongified_id' => 1}
        @collection.should_receive(:find_one).with(query)
        @mongodb_connection.find_one('users', query)
      end
    end

    it "should create index for pre_mongified_id" do
      @collection.should_receive(:create_index).with([["pre_mongified_id", Mongo::ASCENDING]]).and_return(true)
      @mongodb_connection.create_pre_mongified_id_index('users')
    end

    context "remove_pre_mongified_ids" do
      before(:each) do
        @collection.stub(:index_information).and_return('pre_mongified_id_1' => 'something')
      end
      it "should call update with unset" do
        @collection.should_receive(:update).with({},{'$unset' => {'pre_mongified_id' => 1}}, {:multi=>true})
        @collection.stub(:drop_index)
        @mongodb_connection.remove_pre_mongified_ids('users')
      end
      it "should drop the index" do
        @collection.should_receive(:drop_index).with('pre_mongified_id_1')
        @collection.stub(:update)
        @mongodb_connection.remove_pre_mongified_ids('users')
      end
    end
  end

  context "force" do
    before(:each) do
      @mock_connection = double(:connected? => true, :drop_database => true)
      Mongo::Connection.stub(:new).and_return(@mock_connection)
      @mongodb_connection = Mongify::Database::NoSqlConnection.new(:host => 'localhost', :database => 'blue', :force => true)
      Mongify::UI.stub(:ask).and_return(true)
    end
    it "should be true" do
      @mongodb_connection.should be_forced
    end
    it "should be false" do
      Mongify::Database::NoSqlConnection.new(:host => 'localhost', :database => 'blue', :force => false).should_not be_forced
    end

    it "should drop database" do
      @mongodb_connection.connection.should_receive(:drop_database).with('blue').and_return(true)
      @mongodb_connection.send(:drop_database)
    end

    context "ask permission" do
      it "should ask to drop database" do
        Mongify::UI.should_receive(:ask).and_return(false)
        @mongodb_connection.send(:ask_to_drop_database)
      end
      it "should not drop database if permission is declined" do
        Mongify::UI.should_receive(:ask).and_return(false)
        @mongodb_connection.should_receive(:drop_database).never
        @mongodb_connection.send(:ask_to_drop_database)
      end
      it "should drop database if permission is granted" do
        Mongify::UI.should_receive(:ask).and_return(true)
        @mongodb_connection.should_receive(:drop_database).once
        @mongodb_connection.send(:ask_to_drop_database)
      end
    end
  end


  describe "working connection" do
    before(:each) do
      @mongodb_connection = DatabaseGenerator.mongo_connection
    end

    it "should work" do
      @mongodb_connection.should be_valid
      @mongodb_connection.should have_connection
    end

    it "should return a db" do
      @mongodb_connection.db.should be_a Mongify::Database::NoSqlConnection::DB
    end
  end

end

