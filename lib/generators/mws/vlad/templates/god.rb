namespace :vlad do
  set :god_cmd, "god"
  set :god_group, "default"
  set :god_invoke_args, "--no-syslog --pid tmp/pids/god.pid --log log/god.log"
  remote_task :start_app, :roles => :web do
    cmd = []
    cmd << "cd #{current_path}"
    cmd << "#{god_cmd} status > /dev/null || RAILS_ENV=\"#{rails_env}\" #{god_cmd} #{god_invoke_args}"
    Dir.glob('config/*.god').each do |conf|
      cmd << "#{god_cmd} load #{conf}"
    end
    cmd << "#{god_cmd} restart #{god_group}"
    run cmd.join(' && ')
  end
end
