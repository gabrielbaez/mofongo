require "test_helper"

class SubscriptionTest < ActiveSupport::TestCase
  def setup
    @user = users(:regular_user)
    @subscription = subscriptions(:confirmed)
    @unconfirmed = subscriptions(:unconfirmed)
  end
  
  test "valid subscription" do
    subscription = Subscription.new(
      email: "test@example.com",
      name: "Test User"
    )
    assert subscription.valid?
  end
  
  test "invalid without email" do
    subscription = Subscription.new(name: "Test User")
    refute subscription.valid?
    assert_not_nil subscription.errors[:email]
  end
  
  test "invalid with duplicate email" do
    subscription = Subscription.new(
      email: @subscription.email,
      name: "Test User"
    )
    refute subscription.valid?
    assert_not_nil subscription.errors[:email]
  end
  
  test "generates token before create" do
    subscription = Subscription.create!(
      email: "new@example.com",
      name: "New User"
    )
    assert_not_nil subscription.token
  end
  
  test "sets default preferences" do
    subscription = Subscription.create!(
      email: "new@example.com",
      name: "New User"
    )
    assert_includes subscription.preferences, "new_posts"
    assert_includes subscription.preferences, "weekly_digest"
  end
  
  test "confirm! sets confirmed_at" do
    assert_nil @unconfirmed.confirmed_at
    @unconfirmed.confirm!
    assert_not_nil @unconfirmed.confirmed_at
  end
  
  test "confirm! sends welcome email" do
    assert_enqueued_email_with SubscriptionMailer, :welcome_email, args: { params: { subscription: @unconfirmed } } do
      @unconfirmed.confirm!
    end
  end
  
  test "unsubscribe! sets unsubscribed_at" do
    assert_nil @subscription.unsubscribed_at
    @subscription.unsubscribe!
    assert_not_nil @subscription.unsubscribed_at
  end
  
  test "resubscribe! clears unsubscribed_at" do
    @subscription.unsubscribe!
    assert_not_nil @subscription.unsubscribed_at
    @subscription.resubscribe!
    assert_nil @subscription.unsubscribed_at
  end
  
  test "subscribed scope includes only confirmed and not unsubscribed" do
    confirmed = Subscription.create!(
      email: "confirmed@example.com",
      name: "Confirmed User"
    )
    confirmed.confirm!
    
    unsubscribed = Subscription.create!(
      email: "unsubscribed@example.com",
      name: "Unsubscribed User"
    )
    unsubscribed.confirm!
    unsubscribed.unsubscribe!
    
    unconfirmed = Subscription.create!(
      email: "unconfirmed@example.com",
      name: "Unconfirmed User"
    )
    
    subscribed = Subscription.subscribed
    assert_includes subscribed, confirmed
    refute_includes subscribed, unsubscribed
    refute_includes subscribed, unconfirmed
  end
  
  test "by_preference scope returns subscriptions with matching preference" do
    subscription = Subscription.create!(
      email: "test@example.com",
      name: "Test User",
      preferences: ["weekly_digest"]
    )
    subscription.confirm!
    
    assert_includes Subscription.by_preference("weekly_digest"), subscription
    refute_includes Subscription.by_preference("new_posts"), subscription
  end
  
  test "preference? checks if preference is included" do
    @subscription.preferences = ["weekly_digest"]
    assert @subscription.preference?("weekly_digest")
    refute @subscription.preference?("new_posts")
  end
  
  test "add_preference adds new preference" do
    @subscription.preferences = []
    @subscription.add_preference("weekly_digest")
    assert_includes @subscription.preferences, "weekly_digest"
  end
  
  test "remove_preference removes existing preference" do
    @subscription.preferences = ["weekly_digest"]
    @subscription.remove_preference("weekly_digest")
    refute_includes @subscription.preferences, "weekly_digest"
  end
  
  test "display_name returns name if present" do
    @subscription.name = "Test User"
    assert_equal "Test User", @subscription.display_name
  end
  
  test "display_name returns email username if no name" do
    @subscription.name = nil
    @subscription.email = "test.user@example.com"
    assert_equal "test.user", @subscription.display_name
  end
end
