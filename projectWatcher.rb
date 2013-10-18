#!/usr/bin/env ruby

require 'rubygems'
require 'bundler/setup'

require 'kickscraper'
require 'mail'
require 'optparse'
require 'yaml'

options = {}
OptionParser.new do |opts|
  opts.banner = "Usage: projectWatcher.rb [options]"

  opts.on('-p', '--project NAME', 'Project Key') { |v| options[:project_key] = v }
  opts.on('-e', '--email', 'Send as email') { options[:send_email] = true }
end.parse!

#Now raise an exception if we have not found a project_key option
raise OptionParser::MissingArgument if options[:project_key].nil?

kickwatch_config = YAML.load_file('config/config.yml')

projects_config = YAML.load_file('config/project.yml')
project_config = projects_config[options[:project_key]]

Kickscraper.configure do |config|
    config.email = kickwatch_config['kickstarter_email']
    config.password = kickwatch_config['kickstarter_password']
end

if options[:send_email]
    Mail.defaults do
      delivery_method :smtp, {
        :address => 'smtp.gmail.com',
        :port => '587',
        :user_name => kickwatch_config['kickstarter_gamil_username'],
        :password => kickwatch_config['kickstarter_gmail_password'],
        :authentication => :plain,
        :enable_starttls_auto => true
      }
    end
end

client = Kickscraper.client

project = client.find_project(project_config['slug'])

project.rewards.each {|reward|
    if project_config['rewards'].include? reward.id
        reward.name = reward.reward.partition(':').first

        if reward.remaining > 0
            subject = "Kickstarter Alert: Found #{reward.remaining} opening(s) for #{reward.name}"
            body = "#{reward.reward}\n\n#{reward.remaining} Left"

            if options[:send_email]
                Mail.deliver do
                   from     'no-reply@kickstater.com'
                   to       kickwatch_config['kickstarter_email']
                   subject  subject
                   body     body
                end
            else
                puts '==='
                puts subject
                puts body
                puts '==='
            end
        else
            unless options[:send_email]
                puts "No slots open for #{reward.name}"
            end
        end
    end
};
