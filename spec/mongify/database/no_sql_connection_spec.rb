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
      @mock_client = double('Mongo::Client')
      @mock_database = double('Mongo::Database')
      @mock_client.stub(:database).and_return(@mock_database)
      @mock_database.stub(:command).and_return(double)
      Mongo::Client.stub(:new).and_return(@mock_client)
    end

    it "should only create a connection once" do
      Mongo::Client.should_receive(:new).once
      @mongodb_connection.host 'localhost'
      @mongodb_connection.database 'test'
      @mongodb_connection.connection
      @mongodb_connection.connection
    end

    it "should include credentials in client options if username && password is present" do
      @mongodb_connection.host 'localhost'
      @mongodb_connection.database 'test'
      @mongodb_connection.username "bob"
      @mongodb_connection.password "secret"
      Mongo::Client.should_receive(:new).with(
        ["localhost:27017"],
        hash_including(user: "bob", password: "secret", database: "test")
      ).and_return(@mock_client)
      @mongodb_connection.connection
    end
  end


  context "database action:" do
    before(:each) do
      @mongodb_connection.host 'localhost'
      @mongodb_connection.database 'test'
      @collection = double('collection')
      @mock_client = double('Mongo::Client')
      @mock_client.stub(:[]).with('users').and_return(@collection)
      @mongodb_connection.stub(:client).and_return(@mock_client)
    end

    context "insert_into" do
      it "should insert into a table using the mongo driver" do
        @collection.should_receive(:insert_one).with({'first_name' => 'bob'})
        @mongodb_connection.insert_into('users', {'first_name' => 'bob'})
      end
    end

    context "get_id_using_pre_mongified_id" do
      it "should return new id" do
        cursor = double('cursor')
        cursor.stub(:first).and_return({'_id' => '123'})
        @collection.should_receive(:find).with({"pre_mongified_id"=>1}).and_return(cursor)
        @mongodb_connection.get_id_using_pre_mongified_id('users', 1).should == '123'
      end
      it "should return nil if nothing is found" do
        cursor = double('cursor')
        cursor.stub(:first).and_return(nil)
        @collection.should_receive(:find).with({"pre_mongified_id"=>1}).and_return(cursor)
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
        @collection.should_receive(:replace_one).with({"_id" => 1}, attributes)
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

      it "should use replace_one with upsert if _id is present but no pre_mongified_id" do
        attributes = {'_id' => 'abc123', 'post_id' => 123}
        @collection.should_receive(:replace_one).with({"_id" => 'abc123'}, attributes, upsert: true)
        @mongodb_connection.upsert('users', attributes)
      end

      it "should insert if no _id and no pre_mongified_id" do
        attributes = {'post_id' => 123}
        @mongodb_connection.should_receive(:insert_into).with('users', attributes)
        @mongodb_connection.upsert('users', attributes)
      end
    end

    context "find_one" do
      it "should call find and return first result" do
        query = {'pre_mongified_id' => 1}
        cursor = double('cursor')
        cursor.stub(:first).and_return({'_id' => '123'})
        @collection.should_receive(:find).with(query).and_return(cursor)
        @mongodb_connection.find_one('users', query)
      end
    end

    it "should create index for pre_mongified_id" do
      indexes = double('indexes')
      @collection.stub(:indexes).and_return(indexes)
      indexes.should_receive(:create_one).with({ 'pre_mongified_id' => 1 }).and_return(true)
      @mongodb_connection.create_pre_mongified_id_index('users')
    end

    context "remove_pre_mongified_ids" do
      before(:each) do
        @indexes = double('indexes')
        @indexes.stub(:collect).and_return(['pre_mongified_id_1'])
        @collection.stub(:indexes).and_return(@indexes)
      end
      it "should call update_many with unset" do
        @collection.should_receive(:update_many).with({},{'$unset' => {'pre_mongified_id' => 1}})
        @indexes.stub(:drop_one)
        @mongodb_connection.remove_pre_mongified_ids('users')
      end
      it "should drop the index" do
        @indexes.should_receive(:drop_one).with('pre_mongified_id_1')
        @collection.stub(:update_many)
        @mongodb_connection.remove_pre_mongified_ids('users')
      end
    end
  end

  context "force" do
    before(:each) do
      @mock_client = double('Mongo::Client')
      @mock_database = double('Mongo::Database')
      @mock_client.stub(:database).and_return(@mock_database)
      @mock_database.stub(:command).and_return(double)
      @mock_database.stub(:drop).and_return(true)
      Mongo::Client.stub(:new).and_return(@mock_client)
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
      @mock_database.should_receive(:drop).and_return(true)
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
      @mongodb_connection.db.should be_a Mongo::Database
    end
  end

end
