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

gem "sqlite3-ruby", :lib => "sqlite3", :version => ">=1.2.3"

with_options :env => "test" do |test|
	test.gem "rspec", :lib => false, :version => ">=1.2.2"
	test.gem "rspec-rails", :lib => false, :version => ">=1.2.2"
	test.gem "webrat", :lib => false, :version => ">=0.4.3"
	test.gem "cucumber", :lib => false, :version => ">=0.2.2"
end

rake('gems:install')
rake('gems:install', :env => "test")

git :init

with_options :submodule => true do |sub|
	sub.plugin 'semantic_form_builder', :git => 'git://github.com/rubypond/semantic_form_builder.git'
	sub.plugin 'asset_packager', :git => 'git://github.com/sbecker/asset_packager.git'
	sub.plugin "paperclip", :git => "git://github.com/thoughtbot/paperclip.git"
	sub.plugin 'restful-authentication', :git => 'git://github.com/technoweenie/restful-authentication.git'
	sub.plugin 'role_requirement', :git => 'git://github.com/timcharper/role_requirement.git'
end

git :submodule => "init"
git :add => "."
git :commit => "-a -m 'Initial commit'"

puts "MWS template fihished successfully."