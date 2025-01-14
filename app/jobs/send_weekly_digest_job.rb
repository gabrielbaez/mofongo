class SendWeeklyDigestJob < ApplicationJob
  queue_as :mailers
  
  def perform
    # Only send to confirmed subscribers who haven't unsubscribed
    # and have weekly_digest in their preferences
    Subscription.subscribed
               .by_preference('weekly_digest')
               .find_each do |subscription|
      SubscriptionMailer.with(subscription: subscription)
                       .weekly_digest
                       .deliver_later
    end
  end
end
