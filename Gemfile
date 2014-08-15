source 'https://rubygems.org'

ruby '2.0.0'
# Bundle edge Rails instead: gem 'rails', github: 'rails/rails'
gem 'rails', '~> 4.1'

# Use bcrypt for password hashing
gem 'bcrypt', '~> 3.1.5'

# Use paper_trail for versioning
gem 'paper_trail', '~>3.0.3'

# Use SCSS for stylesheets
gem 'sass-rails', '~> 4.0.2'

# Include Twitter's bootstrap.js for ass
gem 'bootstrap-sass', '~> 3.1.1'

# Use Uglifier as compressor for JavaScript assets
gem 'uglifier', '>= 1.3.0'

# Use CoffeeScript for .js.coffee assets and views
gem 'coffee-rails', '~> 4.0.0'

# Allows for easily paginating lists
#gem 'will_paginate', '~> 3.0.5'
#Dont use will_paginate, use kaminari, for active_admin supoort
# gem 'bootstrap-will_paginate', '~> 0.0.10'

# Use jquery as the JavaScript library
gem 'jquery-rails'
gem 'jquery-ui-rails', '~> 5.0.0'

gem 'active_model_serializers', '~> 0.9.0.alpha1'

# Turbolinks makes following links in your web application faster. Read more: https://github.com/rails/turbolinks
gem 'turbolinks'
gem 'jquery-turbolinks'

# Build JSON APIs with ease. Read more: https://github.com/rails/jbuilder
#gem 'jbuilder', '~> 1.2'

#Easy hook to strip whitespace before validations
gem 'auto_strip_attributes', '~> 2.0'

# Use postgres as the database for Active Record
gem 'pg', '~> 0.17.1'

# Use devise for auth
gem 'devise', '~> 3.2.4'


# Rolify master has not been updated in 3 months as of 5/3/2014. jhenkens branch has a few bug-fixes
gem 'rolify', github: 'jhenkens/rolify'

# Allows us to specify what a user 'can' do based on their roles
gem 'cancancan', '~> 1.7.1'

# Use the 3.1.0 RC because it supports BootStrap 3
gem 'mail_form', '~> 1.5.0'

gem 'simple_form', '~> 3.1.0.rc1'

gem 'libxml-ruby', '~> 2.7.0'

gem 'activeadmin', github: 'gregbell/active_admin'
gem 'arbre', '~> 1.0.1'

gem 'acts_as_list', '~> 0.4.0'
gem 'ckeditor', '~> 4.1.0'

#For AWS-ckeditor assets and Laplaya Media
gem 'aws-sdk', '~> 1.51.0'
gem 'paperclip', '~> 4.1.1'
gem 'data_uri', '~> 0.1.0' #for converting data-uris to the actual file to upload to aws

#Host our assets on AWS
gem 'fog', '~>1.20', require: 'fog/aws/storage'
gem 'asset_sync', '~> 1.1.0'


# Restrict javascript to a specific controller, within assett pipeline
gem 'paloma', '~> 4.1.0'

#draw charts for the teacher view
gem 'chartkick', '~> 1.3.2'


group :doc do
  # bundle exec rake doc:rails generates the API under doc/api.
  gem 'sdoc', require: false
end

group :production do
# If running on Heroku
  gem 'rails_12factor'
  gem 'newrelic_rpm'
  gem 'lograge'

end

group :test do
  gem 'selenium-webdriver', '~> 2.42.0'
  gem 'capybara', '~> 2.3.0'
  gem 'poltergeist', '~> 1.5.1'
  gem 'launchy'
end

group :development, :test do
  gem 'dotenv-rails', '~> 0.11.1'
  gem 'factory_girl_rails', '~> 4.4.1'
  gem 'faker', '~> 1.3.0'
  gem 'rspec-rails', '~> 3.0.1'
  gem 'fuubar', '~> 2.0.0rc1'
  gem 'rspec-expectations', '~> 3.0.1'
  gem 'rspec-its', '~> 1.0.1'
  gem 'rspec-collection_matchers', '~> 1.0.0'
  gem 'spork-rails', '~> 4.0.0'
  gem 'guard-rspec', '~> 4.2.8'
  gem 'guard-spork', '~> 1.5.1'
  gem 'childprocess', '~> 0.5.2'
end

group :development do
  #Rubymine debugging
  gem 'ruby-debug-ide'
  gem 'debase'

  #nice debugging in your browser
  gem 'better_errors'
  #allows interpreted ruby while debugging in browser
  gem 'binding_of_caller'
  #enables RailsPanel chrome developer addon
  gem 'meta_request'
  gem 'rack-mini-profiler'

end

# gem 'therubyracer', platforms: :ruby

# Use unicorn as the app server
gem 'unicorn'

gem 'resque'
gem 'resque-loner'

gem 'resque-web', require: 'resque_web'


# Use Capistrano for deployment
# gem 'capistrano', group: :development

# Use debugger

