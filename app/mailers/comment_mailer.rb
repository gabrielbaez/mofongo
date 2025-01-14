class CommentMailer < ApplicationMailer
  def new_comment
    @comment = params[:comment]
    @blog_post = @comment.blog_post
    @post_author = @blog_post.user

    # Send to post author if it's a root comment
    if @comment.parent_id.nil?
      mail(
        to: @post_author.email,
        subject: "New comment on your post: #{@blog_post.title}"
      )
    else
      # Send to parent comment author for replies
      @parent_comment = @comment.parent
      mail(
        to: @parent_comment.user.email,
        subject: "New reply to your comment on: #{@blog_post.title}"
      )
    end
  end
end
