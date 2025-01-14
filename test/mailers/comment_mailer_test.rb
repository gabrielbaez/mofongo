require 'test_helper'

class CommentMailerTest < ActionMailer::TestCase
  def setup
    @user = users(:one)
    @blog_post = blog_posts(:one)
    @comment = Comment.create!(
      content: "Test comment",
      user: users(:two),
      blog_post: @blog_post
    )
  end

  test "new_comment notification for blog post author" do
    email = CommentMailer.with(comment: @comment).new_comment

    assert_emails 1 do
      email.deliver_now
    end

    assert_equal ["notifications@example.com"], email.from
    assert_equal [@blog_post.user.email], email.to
    assert_equal "New Comment", email.subject
    
    # Test email body
    assert_match "You have received a new comment", email.text_part.body.to_s
    assert_match @comment.content, email.text_part.body.to_s
    assert_match @comment.user.email, email.text_part.body.to_s
    assert_match blog_post_url(@blog_post, anchor: "comment-#{@comment.id}"), 
                 email.text_part.body.to_s
  end

  test "new_comment notification for parent comment author" do
    reply = Comment.create!(
      content: "Test reply",
      user: users(:three),
      blog_post: @blog_post,
      parent: @comment
    )

    email = CommentMailer.with(comment: reply).new_comment

    assert_emails 1 do
      email.deliver_now
    end

    assert_equal ["notifications@example.com"], email.from
    assert_equal [@comment.user.email], email.to
    assert_equal "New Reply", email.subject
    
    # Test email body
    assert_match "Someone has replied to your comment", email.text_part.body.to_s
    assert_match reply.content, email.text_part.body.to_s
    assert_match reply.user.email, email.text_part.body.to_s
    assert_match blog_post_url(@blog_post, anchor: "comment-#{reply.id}"), 
                 email.text_part.body.to_s
  end

  test "email preview should be available" do
    preview = ActionMailer::Preview.new.public_send("comment_mailer_preview")
    assert_not_nil preview
  end
end
