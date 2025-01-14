require "test_helper"

class SubscriptionMailerTest < ActionMailer::TestCase
  def setup
    @subscription = subscriptions(:confirmed)
    @blog_post = blog_posts(:published)
    @blog_series = blog_series(:active)
  end
  
  test "confirmation email" do
    email = SubscriptionMailer.with(subscription: @subscription).confirmation
    
    assert_emails 1 do
      email.deliver_now
    end
    
    assert_equal ["no-reply@example.com"], email.from
    assert_equal [@subscription.email], email.to
    assert_equal "Please confirm your blog subscription", email.subject
  end
  
  test "welcome email" do
    email = SubscriptionMailer.with(subscription: @subscription).welcome_email
    
    assert_emails 1 do
      email.deliver_now
    end
    
    assert_equal [@subscription.email], email.to
    assert_equal "Welcome to Mofongo Blog!", email.subject
    assert_includes email.html_part.body.to_s, @subscription.display_name
  end
  
  test "new post email" do
    email = SubscriptionMailer.with(
      subscription: @subscription,
      blog_post: @blog_post
    ).new_post
    
    assert_emails 1 do
      email.deliver_now
    end
    
    assert_equal [@subscription.email], email.to
    assert_equal "New blog post: #{@blog_post.title}", email.subject
    assert_includes email.html_part.body.to_s, @blog_post.title
  end
  
  test "weekly digest email" do
    email = SubscriptionMailer.with(subscription: @subscription).weekly_digest
    
    assert_emails 1 do
      email.deliver_now
    end
    
    assert_equal [@subscription.email], email.to
    assert_match(/Your Weekly Blog Digest/, email.subject)
  end
  
  test "series update email" do
    email = SubscriptionMailer.with(
      subscription: @subscription,
      blog_series: @blog_series,
      blog_post: @blog_post
    ).series_update
    
    assert_emails 1 do
      email.deliver_now
    end
    
    assert_equal [@subscription.email], email.to
    assert_equal "New post in series: #{@blog_series.title}", email.subject
    assert_includes email.html_part.body.to_s, @blog_series.title
    assert_includes email.html_part.body.to_s, @blog_post.title
  end
  
  test "community highlights email" do
    email = SubscriptionMailer.with(subscription: @subscription).community_highlights
    
    assert_emails 1 do
      email.deliver_now
    end
    
    assert_equal [@subscription.email], email.to
    assert_match(/Community Highlights/, email.subject)
  end
end
