require File.join(File.dirname(File.dirname(File.dirname(File.expand_path(__FILE__)))), 'spec_helper')
require File.join(File.dirname(File.dirname(File.dirname(File.dirname(File.expand_path(__FILE__))))), 'lib', 'mongify', 'cli', 'version_command')

include Mongify
include Mongify::CLI

describe VersionCommand do
  before :each do
    @text = 'Piece of interesting text'
    @cmd = VersionCommand.new(@text)
    @view = mock('view', :null_object => true)
  end

  it 'displays the text on the view' do
    @view.expects(:output).with(/#{@text}/)
    puts @cmd.execute(@view)
  end

  it 'displays the Reek version on the view' do
    @view.should_receive(:output).with(/#{Mongify::VERSION}/)
    @cmd.execute(@view)
  end

  it 'tells the view it succeeded' do
    @view.should_receive(:report_success)
    @cmd.execute(@view)
  end
end
