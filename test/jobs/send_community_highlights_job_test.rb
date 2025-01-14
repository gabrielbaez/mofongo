require "test_helper"

class SendCommunityHighlightsJobTest < ActiveJob::TestCase
  def setup
    @subscription = subscriptions(:confirmed)
    @subscription.update!(preferences: ["community_highlights"])
  end
  
  test "enqueues community highlights emails" do
    assert_enqueued_jobs 1, only: ActionMailer::MailDeliveryJob do
      SendCommunityHighlightsJob.perform_now
    end
  end
  
  test "only sends to confirmed subscribers with community_highlights preference" do
    unconfirmed = subscriptions(:unconfirmed)
    unconfirmed.update!(preferences: ["community_highlights"])
    
    unsubscribed = Subscription.create!(
      email: "unsubscribed@example.com",
      preferences: ["community_highlights"]
    )
    unsubscribed.confirm!
    unsubscribed.unsubscribe!
    
    no_preference = Subscription.create!(email: "no_pref@example.com")
    no_preference.confirm!
    
    assert_enqueued_jobs 1, only: ActionMailer::MailDeliveryJob do
      SendCommunityHighlightsJob.perform_now
    end
  end
  
  test "enqueues email with correct parameters" do
    assert_enqueued_email_with SubscriptionMailer, :community_highlights,
        args: { params: { subscription: @subscription } } do
      SendCommunityHighlightsJob.perform_now
    end
  end
end
