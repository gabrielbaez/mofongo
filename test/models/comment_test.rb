require 'test_helper'

class CommentTest < ActiveSupport::TestCase
  def setup
    @user = users(:one)
    @blog_post = blog_posts(:one)
    @comment = Comment.new(
      content: "Test comment",
      user: @user,
      blog_post: @blog_post
    )
  end

  test "should be valid" do
    assert @comment.valid?
  end

  test "should require content" do
    @comment.content = ""
    assert_not @comment.valid?
  end

  test "should require user" do
    @comment.user = nil
    assert_not @comment.valid?
  end

  test "should auto approve on create" do
    @comment.save
    assert @comment.approved?
    assert_not_nil @comment.approved_at
  end

  # Voting tests
  test "vote_by should return user's vote" do
    @comment.save
    vote = Vote.create!(user: @user, comment: @comment, value: 1)
    assert_equal vote, @comment.vote_by(@user)
  end

  test "voted_by? should return true if user voted" do
    @comment.save
    assert_not @comment.voted_by?(@user)
    
    Vote.create!(user: @user, comment: @comment, value: 1)
    assert @comment.voted_by?(@user)
  end

  test "upvoted_by? should return true if user upvoted" do
    @comment.save
    assert_not @comment.upvoted_by?(@user)
    
    Vote.create!(user: @user, comment: @comment, value: 1)
    assert @comment.upvoted_by?(@user)
  end

  test "downvoted_by? should return true if user downvoted" do
    @comment.save
    assert_not @comment.downvoted_by?(@user)
    
    Vote.create!(user: @user, comment: @comment, value: -1)
    assert @comment.downvoted_by?(@user)
  end

  test "update_score should calculate correct values" do
    @comment.save
    
    # Create multiple votes
    Vote.create!(user: users(:one), comment: @comment, value: 1)
    Vote.create!(user: users(:two), comment: @comment, value: 1)
    Vote.create!(user: users(:three), comment: @comment, value: -1)
    
    @comment.update_score
    
    assert_equal 2, @comment.upvotes_count
    assert_equal 1, @comment.downvotes_count
    assert_equal 1, @comment.score  # 2 upvotes - 1 downvote
  end

  # Reply hierarchy tests
  test "should handle parent-child relationship" do
    @comment.save
    reply = Comment.new(
      content: "Test reply",
      user: users(:two),
      blog_post: @blog_post,
      parent: @comment
    )
    
    assert reply.valid?
    assert_equal @comment, reply.parent
    assert_includes @comment.replies, reply
  end

  test "should destroy dependent replies" do
    @comment.save
    reply = Comment.create!(
      content: "Test reply",
      user: users(:two),
      blog_post: @blog_post,
      parent: @comment
    )
    
    assert_difference 'Comment.count', -2 do
      @comment.destroy
    end
  end

  # Notification tests
  test "should not notify post author of their own comment" do
    comment = Comment.new(
      content: "Test comment",
      user: @blog_post.user,
      blog_post: @blog_post
    )
    
    assert_no_enqueued_emails do
      comment.save
    end
  end

  test "should not notify parent comment author of their own reply" do
    @comment.save
    reply = Comment.new(
      content: "Test reply",
      user: @comment.user,
      blog_post: @blog_post,
      parent: @comment
    )
    
    assert_no_enqueued_emails do
      reply.save
    end
  end

  test "should notify post author of new comment" do
    assert_enqueued_email_with CommentMailer, :new_comment do
      Comment.create!(
        content: "Test comment",
        user: users(:two),
        blog_post: @blog_post
      )
    end
  end

  # Scopes tests
  test "root_comments scope should only return top-level comments" do
    @comment.save
    reply = Comment.create!(
      content: "Test reply",
      user: users(:two),
      blog_post: @blog_post,
      parent: @comment
    )
    
    assert_includes Comment.root_comments, @comment
    assert_not_includes Comment.root_comments, reply
  end

  test "recent_first scope should order by creation time" do
    @comment.save
    newer_comment = Comment.create!(
      content: "Newer comment",
      user: users(:two),
      blog_post: @blog_post
    )
    
    comments = Comment.recent_first
    assert_equal newer_comment, comments.first
    assert_equal @comment, comments.second
  end

  test "by_score scope should order by score" do
    low_score_comment = Comment.create!(
      content: "Low score",
      user: users(:one),
      blog_post: @blog_post
    )
    
    high_score_comment = Comment.create!(
      content: "High score",
      user: users(:two),
      blog_post: @blog_post
    )
    
    # Create votes to set different scores
    Vote.create!(user: users(:one), comment: high_score_comment, value: 1)
    Vote.create!(user: users(:two), comment: high_score_comment, value: 1)
    Vote.create!(user: users(:three), comment: low_score_comment, value: -1)
    
    high_score_comment.update_score
    low_score_comment.update_score
    
    comments = Comment.by_score
    assert_equal high_score_comment, comments.first
    assert_equal low_score_comment, comments.last
  end
end
