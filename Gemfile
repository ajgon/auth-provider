# frozen_string_literal: true
source 'https://rubygems.org/'

gem 'rails'
gem 'pg'
gem 'unicorn'
gem 'haml'

gem 'devise'
gem 'doorkeeper'
gem 'omniauth'
gem 'omniauth-google-oauth2'
gem 'omniauth-facebook'
gem 'omniauth-twitter'
gem 'omniauth-github'
gem 'omniauth-instagram'
gem 'omniauth-linkedin-oauth2'
gem 'omniauth-auth_provider', git: 'git@gitlab.xfive.co:internal/omniauth-auth_provider.git'

gem 'rack-cors'
gem 'stringex'
gem 'has_secure_token'
gem 'activerecord-session_store'

group :development, :test do
  gem 'rspec'
  gem 'rspec-rails'
  gem 'simplecov', require: false
  gem 'factory_girl_rails'
  gem 'database_cleaner'
  gem 'thin'

  gem 'better_errors'
  gem 'binding_of_caller'
  gem 'seedbank'
  gem 'powder'

  # Code quality
  gem 'brakeman', require: false
  gem 'rubocop', require: false
  gem 'rubocop-rspec', require: false
  gem 'overcommit', require: false
  gem 'haml-lint', require: false
  gem 'scss-lint', require: false
  gem 'image_optim', require: false
  gem 'gemsurance', require: false
  gem 'bundler-audit', require: false, git: 'https://github.com/rubysec/bundler-audit.git'
  gem 'irbtools-more', require: 'irbtools/binding'
end
