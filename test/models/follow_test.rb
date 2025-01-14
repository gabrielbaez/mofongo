require 'test_helper'

class FollowTest < ActiveSupport::TestCase
  def setup
    @follower = users(:one)
    @followed = users(:two)
    @follow = Follow.new(follower: @follower, followed: @followed)
  end

  test "should be valid" do
    assert @follow.valid?
  end

  test "should require follower" do
    @follow.follower = nil
    assert_not @follow.valid?
  end

  test "should require followed" do
    @follow.followed = nil
    assert_not @follow.valid?
  end

  test "should enforce unique follower-followed combination" do
    @follow.save!
    duplicate_follow = Follow.new(follower: @follower, followed: @followed)
    assert_not duplicate_follow.valid?
  end

  test "should not allow self-following" do
    self_follow = Follow.new(follower: @follower, followed: @follower)
    assert_not self_follow.valid?
    assert_includes self_follow.errors[:follower_id], "can't follow yourself"
  end

  test "should send notification email after create" do
    assert_enqueued_email_with FollowMailer, :new_follower, args: { follow: @follow } do
      @follow.save!
    end
  end
end
