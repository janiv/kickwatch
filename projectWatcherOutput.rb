require 'kickscraper'

Kickscraper.configure do |config|
    config.email = ENV['KICKSTATER_EMAIL']
    config.password = ENV['KICKSTATER_PASSWORD']
end

client = Kickscraper.client

project = client.find_project('the-dice-vault-a-handcrafted-wooden-case-for-gamin')

watchedRewards = [2049887, 2035701, 1997813, 2028311]

project.rewards.each {|reward|
    if watchedRewards.include? reward.id
        reward.name = reward.reward.partition(':').first
        if reward.remaining > 0
            subject = "Kickstarter Alert: Found #{reward.remaining} opening(s) for #{reward.name}"
            body = "#{reward.reward}\n\n#{reward.remaining} Left"

            puts '==='
            puts subject
            puts body
            puts '==='
        else
          puts "No slots open for #{reward.name}"
        end
    end
};
