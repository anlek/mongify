When /^I run mongify (.*)$/ do |args|
  mongify(args)
end

Then /^stdout equals "([^\"]*)"$/ do |report|
  @last_stdout.should == report
end

Then /^it reports:$/ do |report|
  @last_stdout.should == report
end

Then /^stderr reports:$/ do |report|
  @last_stderr.should == report
end

Then /^it succeeds$/ do
  @last_exit_status.should == Mongify::CLI::Application::STATUS_SUCCESS
end

Then /^it reports the current version$/ do
  @last_stdout.should == "mongify #{Mongify::VERSION}\n"
end

Then /^the exit status indicates an error$/ do
  @last_exit_status.should == Mongify::CLI::Application::STATUS_ERROR
end

Then /^it reports the error ['"](.*)['"]$/ do |string|
  @last_stderr.chomp.should == string
end