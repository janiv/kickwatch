job_type :local_command, 'cd :path && :task :output'

set :output, {:error => 'logs/error.log', :standard => 'logs/success.log'}

every 3.minutes do
    local_command "./projectWatcher.rb -p dice_vault -e"
    local_command "./projectWatcher.rb -p shadows -e"
end
