source 'https://rubygems.org'

ruby "3.3.0"

gem 'rails',                   '>= 5.1.7'
gem 'rails-i18n'
gem 'bcrypt',                  git: 'https://github.com/codahale/bcrypt-ruby.git', require: 'bcrypt'
gem 'faker',                   '1.7.3'
gem 'will_paginate',           '>= 3.1.6'
gem 'bootstrap-will_paginate', '1.0.0'
gem 'bootstrap-sass',          '3.4.1'
gem 'puma',                    '4.3.12'
gem 'sass-rails',              '5.0.6'
gem 'uglifier',                '3.2.0'
gem 'coffee-rails',            '4.2.2'
gem 'jquery-rails',            '4.3.1'
gem 'turbolinks',              '5.0.1'
gem 'jbuilder',                '2.7.0'
gem 'roo'
gem 'mysql2',                  '0.5.5'
gem 'coffee-script-source',    '1.8.0'
gem 'aws-sdk'

group :development, :test do
  gem 'dotenv-rails'
  gem 'byebug', '9.0.6', platform: :mri
  gem 'rspec-rails'
end

group :development do
  gem 'web-console',           '3.5.1'
  gem 'listen',                '>= 3.1.5'
  gem 'spring',                '2.0.2'
  gem 'spring-watcher-listen', '2.0.1'
  gem 'wdm',                   '>= 0.1.0'
end

group :test do
  gem 'rails-controller-testing', '1.0.2'
  gem 'minitest',                 '5.10.3'
  gem 'minitest-reporters',       '1.1.14'
  gem 'guard',                    '2.13.0'
  gem 'guard-minitest',           '2.4.4'
end

group :production do
  gem 'pg', '>= 0.21.0'
end

# Windows環境ではtzinfo-dataというgemを含める必要があります
gem 'tzinfo-data', platforms: [:mingw, :mswin, :x64_mingw, :jruby]