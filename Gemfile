source 'https://rubygems.org'

# Bundle edge Rails instead: gem 'rails', github: 'rails/rails'
gem 'rails', '~> 4.1'

# Use bcrypt for password hashing
gem 'bcrypt', '~> 3.1.5'

# Use SCSS for stylesheets
gem 'sass-rails', '~> 4.0.2'

# Include Twitter's bootstrap.js for ass
gem 'bootstrap-sass', '~> 3.1.1'

# Use Uglifier as compressor for JavaScript assets
gem 'uglifier', '>= 1.3.0'

# Use CoffeeScript for .js.coffee assets and views
gem 'coffee-rails', '~> 4.0.0'

# Allows for easily paginating lists
gem 'will_paginate', '~> 3.0.5'
gem 'bootstrap-will_paginate', '~> 0.0.10'

gem 'obfuscate_id', github: 'arikrak/obfuscate_id', branch: 'patch-1'

# Use jquery as the JavaScript library
gem 'jquery-rails'

# Turbolinks makes following links in your web application faster. Read more: https://github.com/rails/turbolinks
gem 'turbolinks'
gem 'jquery-turbolinks'

# Build JSON APIs with ease. Read more: https://github.com/rails/jbuilder
#gem 'jbuilder', '~> 1.2'

#Easy hook to strip whitespace before validations
gem "auto_strip_attributes", "~> 2.0"

# Use postgres as the database for Active Record
gem 'pg', '~> 0.17.1'

# Use devise for auth
gem 'devise', '~> 3.2.4'


# Rolify master has not been updated in 3 months as of 5/3/2014. jhenkens branch has a few bug-fixes
gem 'rolify', github: 'jhenkens/rolify'

# Allows us to specify what a user 'can' do based on their roles
gem 'cancancan', '~> 1.7.1'

# Use the 3.1.0 RC because it supports BootStrap 3
gem 'simple_form', '~> 3.1.0.rc1'

gem 'libxml-ruby', '~> 2.7.0'

group :doc do
  # bundle exec rake doc:rails generates the API under doc/api.
  gem 'sdoc', require: false
end

group :production do
# If running on Heroku
  gem 'rails_12factor'
end

group :test do
  gem 'selenium-webdriver', '2.35.1'
  gem 'capybara', '2.1.0'
end

group :development, :test do
  gem 'factory_girl_rails', '4.2.1'
  gem 'faker', '~> 1.3.0'
  gem 'rspec-rails', '~> 2.14'
  gem 'spork-rails', '~> 4.0.0'
  gem 'guard-rspec', '~> 4.2.8'
  gem 'guard-spork', '~> 1.5.1'
  gem 'childprocess', '~> 0.5.2'
end

group :development do
end

# See https://github.com/sstephenson/execjs#readme for more supported runtimes
# gem 'therubyracer', platforms: :ruby

# Use unicorn as the app server
# gem 'unicorn'

# Use Capistrano for deployment
# gem 'capistrano', group: :development

# Use debugger
# gem 'debugger', group: [:development, :test]

