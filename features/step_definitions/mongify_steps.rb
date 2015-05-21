When /^I run mongify (.*)$/ do |args|
  mongify(args)
end

Then /^stdout equals "([^\"]*)"$/ do |report|
  @last_stdout.should == report
end

Then /^it reports:$/ do |report|
  @last_stdout.gsub(/\s+/, ' ').strip.should == report.gsub(/\s+/, ' ').strip
end

Then /^stderr reports:$/ do |report|
  @last_stderr.should == report
end

Then /^it succeeds$/ do
  puts @last_stderr if @last_stderr
  @last_exit_status.should == Mongify::CLI::Application::STATUS_SUCCESS
end

Then /^it reports the current version$/ do
  @last_stdout.should == "mongify #{Mongify::VERSION}\n"
end

Then /^the exit status indicates an error$/ do
  @last_exit_status.should == Mongify::CLI::Application::STATUS_ERROR
end

Then /^it reports the error ['"](.*)['"]$/ do |string|
  @last_stderr.chomp.should =~ /#{string}/
end



Given /^a database exists$/ do
  DatabaseGenerator.sqlite
end

Then /^it should print out the database schema$/ do
  @last_stdout.should == DATABASE_PRINT
end