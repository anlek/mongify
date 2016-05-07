require 'spec_helper'
describe Mongify::CLI::Command::Help do
  before :each do
    @text = 'Piece of interesting text'
    @cmd = Mongify::CLI::Command::Help.new(@text)
    @view = double('view').as_null_object
  end

  it 'displays the correct text on the view' do
    @view.should_receive(:output).with(@text)
    @cmd.execute(@view)
  end

  it 'tells the view it succeeded' do
    @view.should_receive(:report_success)
    @cmd.execute(@view)
  end
end
