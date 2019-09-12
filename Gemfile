source 'http://rubygems.org'

gem 'rails', '5.2.1'
gem 'jquery-rails'
gem 'constant_cache'
gem 'html5_validators'
gem 'validate_url'
gem 'validate_email'
gem 'rack-oauth2'
gem 'openid_connect'
gem 'activeadmin'
gem 'public_suffix', '< 3.0'
gem 'json-jwt', '<= 1.9.2'

group :development, :test do
  gem 'sqlite3', '~> 1.3.6'
  gem 'test-unit', '~> 3.0'
  gem 'puma'
end

group :test do
  gem 'turn', :require => false
end

group :production do
  gem 'pg', '~> 0.11'
  gem 'rack-ssl', :require => 'rack/ssl'
end

gem "baby_squeel", "~> 1.3"

gem "facebook_oauth", "~> 0.3.0"
