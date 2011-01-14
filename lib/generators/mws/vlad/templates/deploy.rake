namespace :deploy do
  desc "Local updates during deployments."
  task :after_update => [:link_shared, :genconfig, :hoptoad, :newrelic]

  task :link_shared do
    shared_dir = Rails.root + "../../shared"
    shared_config_dir = shared_dir + "config"
    config_dir = Rails.root + "config"

    directory shared_config_dir

    Dir["config/*.sample"].each do |file|
      target_file = shared_dir + file.sub('.sample', '')
      copy file, target_file unless File.exists?(target_file)
    end
    Dir.entries(shared_config_dir).reject do |file|
      file[0] == '.' || File.exists?(shared_config_dir + file)
    end.each do |file|
      link shared_dir + file, config_dir + file
    end
  end

  task :genconfig do
    run "RAILS_ENV=#{Rails.env} rails g configuration #{Rails.env} -f"
  end

  task :hoptoad do
    ENV["TO"] = Rails.env
    ENV["REVISION"] = `git rev-parse head`
    ENV["USER"] = `git config --get user.name`
    Rake::Task['hoptoad:deploy'].invoke
  end

  task :newrelic do
    run "which -s newrelic 2>/dev/null && newrelic_cmd deployments || true"
  end
end
