require 'kickscraper'

Kickscraper.configure do |config|
    config.email = ENV['KICKSTATER_EMAIL']
    config.password = ENV['KICKSTATER_PASSWORD']
end

client = Kickscraper.client

project = client.find_project('the-dice-vault-a-handcrafted-wooden-case-for-gamin')

project.rewards.each {|reward|
    reward.name = reward.reward.partition(':').first
    puts "#{reward.id}: #{reward.name}"
};
