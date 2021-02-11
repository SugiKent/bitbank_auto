# frozen_string_literal: true

# Use this file to easily define all of your cron jobs.
#
# It's helpful, but not entirely necessary to understand cron before proceeding.
# http://en.wikipedia.org/wiki/Cron

# Example:
#
# set :output, "/path/to/my/cron_log.log"
#
# every 2.hours do
#   command "/usr/bin/some_great_command"
#   runner "MyModel.some_method"
#   rake "some:great:rake:task"
# end
#
# every 4.days do
#   runner "AnotherModel.prune_old_records"
# end

# Learn more: http://github.com/javan/whenever

set :output, './cron_log.log'
env :PATH, ENV['PATH']
set :job_template, "/bin/zsh -l -c ':job'"
job_type :rbenv_ruby, 'source ~/.zshrc; cd :path;  bundle exec ruby :task --silent :output'

every 1.minutes do
  rbenv_ruby 'lib/bitbank_auto.rb'
end
