require 'test_helper'

class VoteTest < ActiveSupport::TestCase
  def setup
    @user = users(:one)
    @comment = comments(:one)
    @vote = Vote.new(user: @user, comment: @comment, value: 1)
  end

  test "should be valid" do
    assert @vote.valid?
  end

  test "should require user" do
    @vote.user = nil
    assert_not @vote.valid?
  end

  test "should require comment" do
    @vote.comment = nil
    assert_not @vote.valid?
  end

  test "should require valid value" do
    @vote.value = 0
    assert_not @vote.valid?
    
    @vote.value = 2
    assert_not @vote.valid?
    
    @vote.value = -2
    assert_not @vote.valid?
    
    @vote.value = 1
    assert @vote.valid?
    
    @vote.value = -1
    assert @vote.valid?
  end

  test "should enforce unique user-comment combination" do
    @vote.save
    duplicate_vote = Vote.new(user: @user, comment: @comment, value: -1)
    assert_not duplicate_vote.valid?
  end

  test "should update comment score after save" do
    initial_score = @comment.score
    @vote.save
    assert_not_equal initial_score, @comment.reload.score
  end

  test "should update comment score after destroy" do
    @vote.save
    score_before_destroy = @comment.reload.score
    @vote.destroy
    assert_not_equal score_before_destroy, @comment.reload.score
  end
end
