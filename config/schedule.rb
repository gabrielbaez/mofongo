# Use this file to easily define all of your cron jobs.
# Learn more: http://github.com/javan/whenever

# Set environment
set :environment, ENV['RAILS_ENV']

# Set output log
set :output, 'log/cron.log'

# Set job template to include rbenv
job_type :rake, %Q{export PATH=/usr/local/bin:$PATH; eval "$(rbenv init -)"; \
                   cd :path && RAILS_ENV=:environment bundle exec rake :task --silent :output}
job_type :runner, %Q{export PATH=/usr/local/bin:$PATH; eval "$(rbenv init -)"; \
                     cd :path && RAILS_ENV=:environment bundle exec rails runner :task --silent :output}

# Weekly digest - Every Monday at 9 AM
every :monday, at: '9:00 am' do
  runner "SendWeeklyDigestJob.perform_later"
end

# Community highlights - Every Friday at 3 PM
every :friday, at: '3:00 pm' do
  runner "SendCommunityHighlightsJob.perform_later"
end

# Clean up old notifications - Every day at midnight
every :day, at: '12:00 am' do
  rake "notifications:cleanup"
end

# Update trending posts cache - Every hour
every 1.hour do
  runner "BlogPost.update_trending_cache"
end
