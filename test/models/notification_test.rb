require 'test_helper'

class NotificationTest < ActiveSupport::TestCase
  def setup
    @recipient = users(:one)
    @actor = users(:two)
    @blog_post = blog_posts(:one)
    @notification = Notification.new(
      recipient: @recipient,
      actor: @actor,
      action: 'created_post',
      notifiable: @blog_post
    )
  end

  test "should be valid" do
    assert @notification.valid?
  end

  test "should require recipient" do
    @notification.recipient = nil
    assert_not @notification.valid?
  end

  test "should not require actor" do
    @notification.actor = nil
    assert @notification.valid?
  end

  test "should require notifiable" do
    @notification.notifiable = nil
    assert_not @notification.valid?
  end

  test "should require action" do
    @notification.action = nil
    assert_not @notification.valid?
  end

  test "unread scope should return unread notifications" do
    @notification.save!
    read_notification = Notification.create!(
      recipient: @recipient,
      actor: @actor,
      action: 'created_post',
      notifiable: @blog_post,
      read_at: Time.current
    )
    
    assert_includes Notification.unread, @notification
    assert_not_includes Notification.unread, read_notification
  end

  test "recent scope should return latest notifications" do
    15.times do |i|
      Notification.create!(
        recipient: @recipient,
        actor: @actor,
        action: "action_#{i}",
        notifiable: @blog_post
      )
    end
    
    assert_equal 10, Notification.recent.count
    assert_equal Notification.order(created_at: :desc).first, Notification.recent.first
  end

  test "notify class method should create notification" do
    assert_difference 'Notification.count' do
      Notification.notify(
        recipient: @recipient,
        actor: @actor,
        action: 'created_post',
        notifiable: @blog_post
      )
    end
  end

  test "mark_as_read! should update read_at timestamp" do
    @notification.save!
    assert_nil @notification.read_at
    
    @notification.mark_as_read!
    assert_not_nil @notification.reload.read_at
  end

  test "should broadcast after create" do
    assert_broadcasts("notifications:#{@recipient.id}", 2) do
      @notification.save!
    end
  end
end
