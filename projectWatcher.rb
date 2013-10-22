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
        :port => '875',
        :user_name => kickwatch_config['kickstarter_gamil_username'],
        :password => kickwatch_config['kickstarter_gmail_password'],
        :authentication => :plain,
        :enable_starttls_auto => true
      }
    end
end

client = Kickscraper.client

project = client.find_project(project_config['slug'])

begin
    old_rewards = YAML.load_file("cache/#{project_config['slug']}.yml")
rescue
    old_rewards = nil
end

project.rewards.each {|reward|
    reward.name = reward.reward.partition(':').first
    if old_rewards
        previous_reward = old_rewards.select{|r| r.id == reward.id}.first
    else
        previous_reward = nil
    end

    if project_config['rewards'].include? reward.id
        if reward.remaining > 0
            reward_changed = previous_reward.nil? || previous_reward.remaining == 0
            subject = "Kickstarter Alert: Found #{reward.remaining} opening(s) for #{reward.name}"
            body = "#{reward.reward}\n\n#{reward.remaining} Left"

            if options[:send_email]
                if reward_changed
                    Mail.deliver do
                       from     'no-reply@kickstater.com'
                       to       kickwatch_config['kickstarter_email']
                       subject  subject
                       body     body
                    end
                end
            else
                if reward_changed
                    puts '==='
                    puts subject
                    puts body
                    puts '==='
                else
                    puts "ALERT: #{reward.remaining} slot(s) open for #{reward.name}"
                end
            end
        else
            unless options[:send_email]
                puts "No slots open for #{reward.name}"
            end
        end
    end

    if old_rewards
        unless old_rewards.include? reward
            subject = "Kickstart Alert: New Reward Level \"#{reward.name}\" Found!"
            body = "#{reward.reward}"
            if reward.remaining
                body += "\n\n#{reward.remaining} Left"
            else
                body += "\n\nUnlimited Tier"
            end

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
        end
    end
};

File.open("cache/#{project_config['slug']}.yml", 'w') {|f| f.write project.rewards.to_yaml }
