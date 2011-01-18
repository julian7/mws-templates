namespace :deploy do
  desc "Local updates during deployments."
  task :after_update => [:link_shared, :genconfig, :clear_cache, :hoptoad, :newrelic]

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
    ENV["RAILS_ENV"] = Rails.env
    sh "rails g configuration -f --no-unicorn --resque"
  end

  task :clear_cache do
    File.unlink %(public/javascripts/main.js public/stylesheets/main.css)
  end

  task :hoptoad do
    ENV["TO"] = Rails.env
    ENV["REVISION"] = `git rev-parse head`
    ENV["USER"] = `git config --get user.name`
    Rake::Task['hoptoad:deploy'].invoke
  end

  task :newrelic do
    sh "(bundle exec newrelic deployments || true)"
  end

  task :start_app do
    god_cmd = "god -p #{Rails.application.class.parent.to_s.underscore}"
    god_invoke_args = "--no-syslog --pid tmp/pids/god.pid --log log/god.log"
    sh "#{god_cmd} status > /dev/null || #{god_cmd} #{god_invoke_args}"
    Dir.glob('config/*.god').each do |conf|
      sh "#{god_cmd} load #{conf}"
    end
    %x(#{god_cmd} status).each_line do |line|
      if group = line.match(/^(\S+):$/)
        sh "#{god_cmd} restart #{group[1]}"
      end
    end
  end

  task :terminate_app do
    sh "god -p #{Rails.application.class.parent.to_s.underscore} terminate"
  end
end
