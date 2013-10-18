require 'kickscraper'
require 'mail'

Kickscraper.configure do |config|
    config.email = ENV['KICKSTATER_EMAIL']
    config.password = ENV['KICKSTATER_PASSWORD']
end

client = Kickscraper.client

project = client.find_project('the-dice-vault-a-handcrafted-wooden-case-for-gamin')

watchedRewards = [2049887, 2035701, 1997813, 2028311]

project.rewards.each {|reward|
    if watchedRewards.include? reward.id
        if reward.remaining > 0
            reward.name = reward.reward.partition(':').first
            subject = "Kickstarter Alert: Found #{reward.remaining} opening(s) for #{reward.name}"
            body = "#{reward.reward}\n\n#{reward.remaining} Left"

            Mail.deliver do
               from     ENV['KICKWATCH_ALERT_FROM']
               to       ENV['KICKWATCH_ALERT_TO']
               subject  subject
               body     body
            end
        end
    end
};
