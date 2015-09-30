source 'https://rubygems.org'

gem 'activesupport'
gem 'google-api-client'
gem 'logging', '~> 1.8' # 2.0 is not compatible with blazing
# beta1 fixes this issue https://github.com/railsconfig/rails_config/pull/86
gem 'mysql2'
gem 'rails_config', '~> 0.5.0.beta1'
gem 'rake'
gem 'sequel'
gem 'sidekiq'
gem 'sidekiq-cron'
gem 'trogdir_api_client'

group :development, :test do
  gem 'pry'
  gem 'pry-rescue'
  gem 'pry-stack_explorer'
  gem 'rspec'
end

group :production do
  gem 'sentry-raven'
end
