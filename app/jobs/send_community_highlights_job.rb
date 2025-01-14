class SendCommunityHighlightsJob < ApplicationJob
  queue_as :mailers
  
  def perform
    # Only send to confirmed subscribers who haven't unsubscribed
    # and have community_highlights in their preferences
    Subscription.subscribed
               .by_preference('community_highlights')
               .find_each do |subscription|
      SubscriptionMailer.with(subscription: subscription)
                       .community_highlights
                       .deliver_later
    end
  end
end
