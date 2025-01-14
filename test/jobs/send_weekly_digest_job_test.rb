require "test_helper"

class SendWeeklyDigestJobTest < ActiveJob::TestCase
  def setup
    @subscription = subscriptions(:confirmed)
    @subscription.update!(preferences: ["weekly_digest"])
  end
  
  test "enqueues weekly digest emails" do
    assert_enqueued_jobs 1, only: ActionMailer::MailDeliveryJob do
      SendWeeklyDigestJob.perform_now
    end
  end
  
  test "only sends to confirmed subscribers with weekly_digest preference" do
    unconfirmed = subscriptions(:unconfirmed)
    unconfirmed.update!(preferences: ["weekly_digest"])
    
    unsubscribed = Subscription.create!(
      email: "unsubscribed@example.com",
      preferences: ["weekly_digest"]
    )
    unsubscribed.confirm!
    unsubscribed.unsubscribe!
    
    no_preference = Subscription.create!(email: "no_pref@example.com")
    no_preference.confirm!
    
    assert_enqueued_jobs 1, only: ActionMailer::MailDeliveryJob do
      SendWeeklyDigestJob.perform_now
    end
  end
  
  test "enqueues email with correct parameters" do
    assert_enqueued_email_with SubscriptionMailer, :weekly_digest,
        args: { params: { subscription: @subscription } } do
      SendWeeklyDigestJob.perform_now
    end
  end
end
