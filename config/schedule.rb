job_type :local_command, 'cd :path && :task :output'

set :output, {:error => 'logs/error.log', :standard => 'logs/success.log'}

every 3.minutes do
end
