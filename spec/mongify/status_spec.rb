require 'spec_helper'

describe Mongify::Status do
  it "should warn if it's an unknown notification" do
    Mongify::UI.should_receive(:warn).at_least(1)
    Mongify::Status.publish('unknwon')
  end
  context "publish" do
    before(:each) do
      @bar = double(:title= => '')
      Mongify::Status.bars.stub(:[]).and_return(@bar)
    end
    it "should create a new progress bar" do
      Mongify::ProgressBar.should_receive(:new)
      Mongify::Status.publish('copy_data', :size => 100, :action => 'add')
    end
    context "on inc" do
      before(:each) do
        @bar.stub(:inc)
      end
      it "should inc a already created progress bar" do
        @bar.should_receive(:inc)
        Mongify::Status.publish('copy_data', :action => 'inc')
      end
      it "should inc by default action" do
        @bar.should_receive(:inc)
        Mongify::Status.publish('copy_data')
      end
    end
    it "should finish the progress bar" do
      @bar.should_receive(:finish)
      Mongify::Status.publish('copy_data', :action => 'finish')
    end
  end
end
