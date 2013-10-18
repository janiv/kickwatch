#!/usr/bin/env ruby

require 'rubygems'
require 'bundler/setup'

require 'kickscraper'
require 'optparse'
require 'yaml'

options = {}
OptionParser.new do |opts|
  opts.banner = "Usage: rewardInfo.rb [options]"

  opts.on('-p', '--project NAME', 'Project Key') { |v| options[:project_key] = v }
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

client = Kickscraper.client

project = client.find_project(project_config['slug'])

project.rewards.each {|reward|
    reward.name = reward.reward.partition(':').first
    puts "#{reward.id}: #{reward.name}"
};
