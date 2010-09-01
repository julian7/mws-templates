# Removing unnecessary stuff
remove_file 'README'
remove_file 'public/index.html'
remove_file 'public/favicon.ico'
remove_file 'public/robots.txt'
remove_file 'public/images/rails.png'

# Set up RVM
create_file '.rvmrc', <<-EnD
rvm use #{ENV['rvm_ruby_string']}@#{app_name} --create > /dev/null
EnD

run 'rvm rvmrc trust'

# Keep directories in Git
run "touch {public/images,tmp/{cache,pids,sessions,sockets},log}/.gitignore"

# Configuration
## Database config
append_file ".gitignore", 'config/database.yml'
create_file 'config/database.yml.sample' do
  File.binread('config/database.yml')
end

## Unicorn config
create_file 'config/unicorn.rb', <<-EnD
rails_env = ENV['RAILS_ENV'] || 'production'
root_dir = File.dirname(__FILE__) + '/..'
worker_processes (rails_env == 'production' ? 16 : 4)
timeout 30
if rails_env.eql?('development')
  listen '127.0.0.1:3000'
end
listen "unix:\#{root_dir}/tmp/sockets/unicorn.sock", :backlog => 2048
pid "\#{root_dir}/tmp/pids/unicorn.pid"
EnD

# Gemfile
gem 'haml'
gem 'jquery-rails'
gem 'devise'
gem 'cancan'
gem 'will_paginate', :git => 'http://github.com/mislav/will_paginate.git', :branch => 'rails3'
gem 'mysql2'
gem 'formtastic', '1.1.0.beta'
gem 'inploy'
gem 'inploy_godlike'
gem 'god'
gem 'unicorn'

append_file 'Gemfile', <<-EnD
group :development, :test do
  gem 'sqlite3-ruby', :require => 'sqlite3'
  gem 'rails3-generators'
  gem 'rspec-rails', '~> 2.0.0.beta.19'
  gem 'capybara'
  gem 'shoulda'
  gem 'cucumber-rails'
  gem 'database_cleaner'
  gem 'factory_girl_rails'
  gem 'email_spec'
  # gem 'grit' # for code beautifier TextMate bundle
end
EnD

run 'bundle install'

# Deployment
create_file 'config/deploy.rb', <<EnD
# depoy.template = 'rails3tags'
# deploy.repository = "git@github.com/username/#{app_name}.git"

case ENV['environment']
when 'development'
  deploy.application = "#{app_name}"
  deploy.user = 'DEVUSER' # app username
  deploy.hosts = ['DEVELOPMENT_APP_SERVER']
  deploy.path = "/var/www/webapps/#{app_name}"
  deploy.server = :godlike
  deploy.god_group = "#{app_name}"
when 'staging'
  deploy.application = "#{app_name}"
  deploy.user = 'STGUSER'
  deploy.hosts = ['STAGING_APP_SERVER']
  deploy.path = "/var/www/webapps/#{app_name}-\#{ENV['environment']}"
  deploy.server = :godlike
  deploy.god_group = "#{app_name}"
  # deploy.tag = 'iterationN'
when 'production'
  deploy.application = "#{app_name}"
  deploy.user = 'PRODUSER'
  deploy.hosts = ['PRODUCTION_APP_SERVER']
  deploy.path = "/var/www/webapps/#{app_name}-\#{ENV['environment']}"
  deploy.server = :godlike
  deploy.god_group = "#{app_name}"
  # deploy.tag = 'releaseN'
else
  deploy.application = "#{app_name}"
  deploy.user = 'USERNAME'
  deploy.hosts = ['OTHER_APP_SERVER']
  deploy.path = '/var/www/HOSTNAME/apps'
  deploy.server = :unicorn
end
EnD

# Controllers
## ApplicationController
inject_into_file 'app/controllers/application_controller.rb', :before => '\nend' do
  <<-EnD
    before_filter :set_user_language
    rescue_from CanCan::AccessDenied, :with => :access_denied
    rescue_from SecurityError, :with => :access_denied
    rescue_from ActiveRecord::RecordNotFound, :with => :not_found

    private

      def set_user_language
        if params.key?(:locale) and !params[:locale].blank?
          I18n.locale = params[:locale]
        elsif I18n.locale.blank?
          I18n.locale = params[:locale] = I18n.default_locale
        end
      end

      def access_denied(e)
        flash.alert = if e.respond_to?(:to_s)
          e.to_s
        else
          t(:accessdenied)
        end
      end

      def not_found
        render :file => "\#{Rails.root}/public/404.html", :status => 404
      end
  EnD
end
# Views
## jQuery
generate 'jquery:install'
## Formtastic
generate 'formtastic:install'
## Layout
remove_file 'app/views/layouts/application.html.erb'
create_file 'app/views/layouts/application.html.haml', <<-EnD
!!! 5
%html
  %head
    %meta{:charset => 'utf-8'}
    %meta{"http-equiv" => 'X-UA-Compatible', :content => 'IE=edge,chrome=1'}
    %title #{app_name.humanize}
    = stylesheet_link_tag :all, :cache => true
    = javascript_include_tag :defaults, :cache => true
    = csrf_meta_tag
  %body
    = yield
EnD

# Models
## CanCan
create_file 'app/models/ability.rb', <<-EnD
# encoding: utf-8

class Ability
  include CanCan::Ability

  def initialize(user)
    can :manage, :all
  end
end
EnD

# RSpec
generate 'rspec:install'
# Devise
generate 'devise:install'
## Devise helper for RSpec
create_file 'spec/support/devise.rb', <<-EnD
# encoding: utf-8
include Devise::TestHelpers

def login_user(group = nil)
  @current_user = Factory(:user)
  User.stub(:find => @current_user)
  if (group)
    ug = Factory(:group, :name => group.to_s.camelcase)
    @current_user.stub!(:groups).and_return([ug])
  end
  sign_in :user, @current_user
end

def should_be_allowed
  controller.should_not_receive(:access_denied)
end

def should_be_forbidden
  controller.should_receive(:access_denied)
end

def should_be_allowed_for(group)
  login_user(group)
  should_be_allowed
end

def should_be_forbidden_for(group)
  login_user(group)
  should_be_forbidden
end
EnD
generate 'cucumber:skeleton --capybara --rspec'

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
