begin
  require 'vlad'
  # Vlad.load :app => :nil,
  Vlad.load :app => :passenger,
    :scm => :git, :web => nil
rescue
  # do nothing
end

namespace :vlad do
  desc "Deploys stack; please set 'to' variable (dev (default), stg)."
  task :deploy => %w{vlad:update vlad:bundle:install vlad:before_start_app vlad:start_app vlad:cleanup}

  remote_task :setup_app, :roles => :app do
    rvmrc = File.binread(Rails.root + ".rvmrc.sample")
    run [
      "cd #{deploy_to}",
      "echo \"#{rvmrc}\" > .rvmrc",
      "rvm rvmrc trusted"
    ].join(' && ')
  end

  remote_task :before_start_app, :role => :app do
    run [
      "cd #{current_path}",
      "export RAILS_ENV=\"#{rails_env}\"",
      "rake deploy:after_update",
      "rake deploy:start_app"
    ].join(" && ")
  end
end
