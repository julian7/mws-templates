rails_env  = "<%= Rails.env %>"
rails_root = "<%= Rails.root %>"

God.watch do |w|
  pidfile = "#{rails_root}/tmp/pids/unicorn.pid"
  w.name = 'worker-0'
  w.group = 'unicorn'
  w.interval = 30.seconds
  w.start = "cd #{rails_root} && unicorn_rails -c config/unicorn.rb -E #{rails_env} -D"
  w.stop = "kill -QUIT `cat #{pidfile}`"
  w.restart = "kill -USR2 `cat #{pidfile}`"
  w.start_grace = 30.seconds
  w.restart_grace = 30.seconds
  w.pid_file = pidfile

  w.behavior(:clean_pid_file)

  w.start_if do |start|
    start.condition(:process_running) do |c|
      c.interval = 5.seconds
      c.running = false
    end
  end
  
  w.restart_if do |restart|
    restart.condition(:memory_usage) do |c|
      c.above = 300.megabytes
      c.times = [3, 5]
    end
    
    restart.condition(:cpu_usage) do |c|
      c.above = 50.percent
      c.times = 5
    end
  end
  
  w.lifecycle do |on|
    on.condition(:flapping) do |c|
      c.to_state = [:start, :restart]
      c.times = 5
      c.within = 5.minute
      c.transition = :unmonitored
      c.retry_in = 10.minutes
      c.retry_times = 5
      c.retry_within = 2.hours
    end
  end
end