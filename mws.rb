# Removing unnecessary stuff
remove_file 'README'
remove_file 'public/index.html'
remove_file 'public/favicon.ico'
remove_file 'public/robots.txt'
remove_file 'public/images/rails.png'

# Set up RVM
create_file '.rvmrc', <<-EnD
rvm_gemset_create_on_use_flag=1
rvm gemset use #{app_name} > /dev/null
EnD

# JQuery
get 'http://ajax.googleapis.com/ajax/libs/jquery/1.4.2/jquery.min.js', 'public/javascripts/jquery.js'
get 'http://ajax.googleapis.com/ajax/libs/jqueryui/1.8.1/jquery-ui.min.js', 'public/javascripts/jquery-ui.js'
get 'http://github.com/rails/jquery-ujs/raw/master/src/rails.js', 'public/javascripts/rails.js'

initializer 'jquery.rb', <<-EnD
module ActionView::Helpers::AssetTagHelper
  remove_const :JAVASCRIPT_DEFAULT_SOURCES
  JAVASCRIPT_DEFAULT_SOURCES = %w(jquery.js jquery-ui.js rails.js)

  reset_javascript_include_default
end
EnD

# Keep directories in Git
run "touch {public/images,tmp/{cache,pids,sessions,sockets},log}/.gitkeep"

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
gem 'devise', :git => 'git://github.com/plataformatec/devise.git'
# Rails 3.0.0.beta4-aware Devise has not been released yet
#gem 'devise', '>=1.1.rc1'
gem 'cancan'
gem 'will_paginate', '3.0.pre'
gem 'ruby-mysql', '>= 2.9.2', :require => 'mysql'
gem 'formtastic', :git => 'http://github.com/justinfrench/formtastic.git', :branch => 'rails3'
gem 'sqlite3-ruby', '>=1.3.0', :require => 'sqlite3'

append_file 'Gemfile', <<-EnD
group :development do
  gem 'rails3-generators'
  gem 'grit'
end

group :test do
  gem 'test-unit', '=1.2.3', :require => 'test/unit'
  gem 'rspec-rails', '>= 2.0.0.beta.12'
  gem 'webrat'
  gem 'cucumber-rails'
  gem 'database_cleaner'
  gem 'factory_girl_rails'
end
EnD

# Deployment
rakefile 'load_inploy.rake', <<EnD
begin
  $:.push Rails.root + 'lib'
  load 'tasks/inploy.rake'
rescue LoadError
  # silently ignore
end
EnD

create_file 'config/deploy.rb', <<EnD
# depoy.template = 'selectbygittag'
# deploy.repository = "git@github.com/username/#{app_name}.git"

case ENV['environment']
when 'development'
  deploy.application = "#{app_name}"
  deploy.user = 'DEVUSER' # app username
  deploy.hosts = ['web2.js.hu']
  deploy.path = '/var/www/#{app_name}.dev.js.hu/apps'
  deploy.environment = :dev
when 'staging'
  deploy.application = "#{app_name}"
  deploy.user = 'DEVUSER'
  deploy.hosts = ['web2.js.hu']
  deploy.path = '/var/www/#{app_name}.stg.js.hu/apps'
  deploy.server = :unicorn
  # deploy.tag = 'iterationN'
else
  deploy.application = 'APP'
  deploy.user = 'USERNAME'
  deploy.hosts = ['web2.js.hu']
  deploy.path = '/var/www/HOSTNAME/apps'
  deploy.server = :unicorn
  # deploy.tag = 'releaseN'
end
EnD

# generate 'formtastic_stylesheets'

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
## Layout
remove_file 'app/views/layouts/application.html.erb'
create_file 'app/views/layouts/application.html.haml', <<-EnD
!!! 5
%html
  %head
    %title #{app_name.humanize}
    = stylesheet_link_tag :all
    = javascript_include_tag :defaults
    = csrf_meta_tag
  %body
    = yield
EnD

run 'gem install bundler'
run 'bundle install'
run 'bundle lock'

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
generate 'cucumber:skeleton --webrat --rspec'

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
