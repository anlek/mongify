require 'spec_helper'

describe Mongify::CLI::Command::Version do
  before :each do
    @text = 'Piece of interesting text'
    @cmd = Mongify::CLI::Command::Version.new(@text)
    @view = double('view').as_null_object
  end

  it 'displays the text on the view' do
    @view.expects(:output).with(/#{@text}/)
    @cmd.execute(@view)
  end

  it 'displays Mongify version on the view' do
    @view.should_receive(:output).with(/#{Mongify::VERSION}/)
    @cmd.execute(@view)
  end

  it 'tells the view it succeeded' do
    @view.should_receive(:report_success)
    @cmd.execute(@view)
  end
end
