rails_env = ENV['RAILS_ENV'] || 'production'
root_dir = File.dirname(__FILE__) + '/..'
worker_processes (rails_env == 'production' ? 16 : 4)
timeout 30
if rails_env.eql?('development')
  listen '127.0.0.1:3000'
end
listen "unix:\#{root_dir}/tmp/sockets/unicorn.sock", :backlog => 2048
pid "\#{root_dir}/tmp/pids/unicorn.pid"
