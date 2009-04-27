run "rm README"
run "rm public/index.html"
run "rm public/favicon.ico"
run "rm public/robots.txt"

run "touch {tmp,log,vendor}/.gitignore"
file ".gitignore", <<EnD
.DS_Store
log/*.log
tmp/**/*
config/database.yml
db/*.sqlite3
doc/api
doc/app
EnD

file "lib/tasks/vlad.rake", <<EnD
begin
  require 'vlad'
  Vlad.load
rescue LoadError
  # do nothing
end
EnD

file "config/deploy.rb", <<EnD
set :application, "app"
set :domain, "example.com"
set :deploy_to, "/var/www/apps"
set :web, "passenger"
set :scm, "git"
set :repository, ""
EnD

gem "sqlite3-ruby", :lib => "sqlite3", :version => ">=1.2.3"
gem "vlad", :lib => false, :version => ">=1.3.2"

with_options :env => "test" do |test|
  test.gem "rspec", :lib => false, :version => ">=1.2.2"
  test.gem "rspec-rails", :lib => false, :version => ">=1.2.2"
  test.gem "webrat", :lib => false, :version => ">=0.4.3"
  test.gem "cucumber", :lib => false, :version => ">=0.3.0"
  test.gem 'thoughtbot-factory_girl', :lib => 'factory_girl', :source => "http://gems.github.com", :version => '>=1.2.1'
end

with_options :sudo => ask("Sudo?") do |r|
  r.rake('gems:install')
  r.rake('gems:install', :env => "test")
end

generate('cucumber')

git :init

with_options :submodule => true do |sub|
# sub.plugin 'semantic_form_builder', :git => 'git://github.com/rubypond/semantic_form_builder.git'
  sub.plugin 'formtastic', :git => 'git://github.com/justinfrench/formtastic.git'
  sub.plugin 'asset_packager', :git => 'git://github.com/sbecker/asset_packager.git'
  sub.plugin 'paperclip', :git => 'git://github.com/thoughtbot/paperclip.git'
  sub.plugin 'clearance', :git => 'git://github.com/thoughtbot/clearance.git'
# sub.plugin 'restful-authentication', :git => 'git://github.com/technoweenie/restful-authentication.git'
# I hope role_requirement works with clearance too
  sub.plugin 'role_requirement', :git => 'git://github.com/timcharper/role_requirement.git'
end

generate('formtastic_stylesheets')

git :submodule => "init"
git :add => "."
git :commit => '-m "Initial commit"'

puts "MWS template fihished successfully."