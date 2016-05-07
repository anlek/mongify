require 'spec_helper'

describe Mongify::Database::DataRow do
  before(:each) do
    @hash = {'first_name' => 'Timmy', 'last_name' => 'Zuza', 'age' => 21, 'create_at' => Time.now}
    @datarow = Mongify::Database::DataRow.new(@hash)
  end
  it "should have method access to hash values" do
    @datarow.first_name.should == 'Timmy'
  end

  it "should dup the hash" do
    @hash = {:first_name => 'Bob'}
    @hash.should_receive(:dup).and_return(@hash)
    dr = Mongify::Database::DataRow.new(@hash)
  end
  it "should strigify_keys!" do
    @hash = {:first_name => 'Bob'}
    @hash.stub(:dup).and_return(@hash)
    @hash.should_receive(:stringify_keys!)
    dr = Mongify::Database::DataRow.new(@hash)
  end

  it "should have a working include? method" do
    @datarow.should include('first_name')
  end

  it "should be able to set a value" do
    @datarow.first_name = 'Bob'
    @datarow.first_name.should == 'Bob'
  end
  it "should allow me to set a new key" do
    @datarow.height = 6
    @datarow.should include('height')
    @datarow.height.should == 6
  end

  it "should to_hash" do
    @datarow.to_hash.should == @hash
  end

  it "should allow inspect" do
    @datarow.inspect.should == @hash.inspect
  end

  context "delete" do
    it "should delete key" do
      @datarow.delete('age')
      @datarow.should_not include('age')
    end
    it "should return value of item being delete" do
      age = @datarow.age
      @datarow.delete('age').should == age
    end
  end

  it "should work with an empty hash" do
    dr = Mongify::Database::DataRow.new({})
    dr.keys.should be_empty
  end

  it "should return all keys in object" do
    @datarow.keys.should == @hash.keys
  end

  context "respond_to" do
    it "should be true for first_name" do
      @datarow.respond_to?('first_name').should be_truthy
    end
    it "should be true for first_name=" do
      @datarow.respond_to?('first_name=').should be_truthy
    end
  end

  context "read_attributes" do
    it "should read attributes" do
      @datarow.read_attribute('first_name').should == @hash['first_name']
    end
    it "should read attributes like delete" do
      @datarow.delete=true
      @datarow.read_attribute('delete').should be_truthy
    end
    it "should read non existing attributes" do
      @datarow.read_attributes('monkey').should be_nil
    end
  end

  context "write_attribute" do
    it "should write attributes" do
      @datarow.write_attribute('first_name', 'Sam')
      @datarow.first_name.should == 'Sam'
    end
    it "should write non existing attributes" do
      @datarow.write_attribute('apple', 'good')
      @datarow.apple.should == "good"
    end
    it "should write attributes like delete" do
      @datarow.write_attribute('delete', 'yes')
      @datarow.read_attribute('delete').should == "yes"
    end
  end
end
