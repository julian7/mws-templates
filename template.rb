# Removing unnecessary stuff
%w(README.rdoc public/index.html public/favicon.ico public/robots.txt app/assets/images/rails.png).each do |f|
  remove_file f
end

# Configuration
append_file ".gitignore", <<-EnD
/config/*.god
/config/database.yml
/vendor/ruby
/vendor/cache
EnD

create_file 'config/database.yml.sample' do
  File.binread('config/database.yml')
end

# Gemfile
gem_group :assets do
  gem 'compass_twitter_bootstrap'
  gem 'compass-rails'
end

gem 'slim-rails'

gem_group :development do
  gem 'guard-minitest', '~> 0.5.0.rc'
  gem 'vlad',  '~> 2.2.5'
  gem 'vlad-git', '~> 2.2.0'
end

gem_group :test do
  gem 'minitest', '~> 2.11.2'
  gem 'capybara', '~> 1.1.2'
  gem 'database_cleaner', '~> 0.7.1'
  gem 'factory_girl_rails', '~> 1.7.0'
  gem 'turn', '~> 0.9.3'
end

## Layout
remove_file 'app/assets/stylesheets/application.css'
create_file 'app/assets/stylesheets/application.css.scss' do
  <<-EnD
@import "compass_twitter_bootstrap";
@import "compass_twitter_bootstrap_responsive";
@import "application/**/*";
EnD
end

create_file 'app/assets/javascripts/application.js' do
  <<-EnD
//= require jquery
//  require jquery-ui
//= require jquery_ujs
//  require bootstrap-...
//= require_tree .
  EnD
end

# Testing framework
create_file 'lib/tasks/minitest.rake' do
  <<-EnD
require 'rake/testtask'

Rake::TestTask.new(name: :spec) do |t|
  t.libs << 'spec'
  t.pattern = 'spec/**/*_spec.rb'
end

desc 'Run specs'
task spec: "db:test:prepare"
  EnD
end

create_file 'spec/minitest_helper.rb' do
  <<-EnD
ENV['RAILS_ENV'] = 'test'
require_relative '../config/environment'
require 'minitest/autorun'
require 'capybara/rails'
require 'active_support/testing/setup_and_teardown'

Dir[File.expand_path('spec/support/*.rb')].each { |file| require file }

DatabaseCleaner.strategy = :truncation
class MiniTest::Spec
  before :each do
    DatabaseCleaner.clean
  end
end

class IntegrationSpec < MiniTest::Spec
  include Rails.application.routes.url_helpers
  include Capybara::DSL
  register_spec_type(/integration$/i, self)
end

class HelperSpec < MiniTest::Spec
  include ActiveSupport::Testing::SetupAndTeardown
  include ActionView::TestCase::Behavior
  register_spec_type(/Helper$/, self)
end
  EnD
end

git :init
git add: "."
git commit: '-m "Initial commit"'

log <<-EnD
MWS template fihished successfully. Now you can run bundle like this:

    bundle install --path=vendor --binstubs --shebang=ruby-local-exec

You may want to use mws-templates gem for other tasks as well:

* mws:layout: generates a standard layout we build on.
* mws:vlad: generates necessary files for deployment.
* mws:auth: generates basic authentication / authorization template with proper specs.
* mws:scaffold: our standard crud scaffold (to be exported).
EnD
