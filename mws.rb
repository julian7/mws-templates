# Removing unnecessary stuff
remove_file 'README'
remove_file 'public/index.html'
remove_file 'public/favicon.ico'
remove_file 'public/robots.txt'
remove_file 'public/images/rails.png'

# Set up RVM
create_file '.rvmrc', <<-EnD
rvm #{ENV['rvm_ruby_string']}@#{app_name}
EnD

run 'rvm rvmrc trust'
create_file '.rvmrc.sample' do
  File.binread('.rvmrc')
end

run 'gem install --no-ri --no-rdoc bundler'

# Keep directories in Git
run "touch {public/images,tmp/{cache,pids,sessions,sockets},log}/.gitignore"

# Configuration
append_file ".gitignore", <<-EnD
config/unicorn.god
config/database.yml
.rvmrc
EnD

create_file 'config/database.yml.sample' do
  File.binread('config/database.yml')
end

# Gemfile
gem 'slim', :require => 'slim/rails'
gem 'sass', '~> 3.1.0.alpha.206'
gem 'jquery-rails'
gem 'devise'
gem 'cancan'
gem 'will_paginate', '~> 3.0.pre2'
gem 'mysql2'
gem 'formtastic', '~> 1.2.0'

append_file 'Gemfile', <<-EnD
#gem 'god', :group => :production  # For now god is broken under 1.9.2
#gem 'unicorn', :group => :production # Don't put unicorn now, stick with passenger for now

group :development, :test do
  gem 'sqlite3-ruby', :require => 'sqlite3'
  gem 'rails3-generators'
  gem 'mws-templates', :path => '/Users/js/Code/mws-templates'
  gem 'passenger'
  # IRB extensions
  gem 'hirb'
  # deployment
  gem 'vlad', '~> 2.1.0'
  gem 'vlad-git', '~> 2.2.0'
  # Behavior test
  gem 'cucumber-rails'
  gem 'capybara'
  gem 'database_cleaner'
  gem 'email_spec'
  # Unit test
  gem 'rspec-rails'
  gem 'webrat'
  gem 'shoulda'
  gem 'factory_girl_rails'
end
EnD

run 'bundle install'

## Layout
generate 'jquery:install'
generate 'formtastic:install'
remove_file 'app/views/layouts/application.html.erb'
generate 'mws:layout'

# Authentication
generate 'devise:install'
generate 'mws:auth'

# Deployment
generate 'mws:vlad --env stg'

# Testing framework
generate 'rspec:install'
generate 'cucumber:install --capybara --rspec'

git :init
git :submodule => "init"
git :add => "."
git :commit => '-m "Initial commit"'

log <<-EnD
MWS template fihished successfully. Please take time to set up authentication user model:

  rails generate devise <model>

and make adjustments to
  app/controllers/action_controller.rb -- http://wiki.github.com/ryanb/cancan/changing-defaults
  app/models/ability.rb
  spec/support/devise.rb
if you're not going to use user model.
EnD
