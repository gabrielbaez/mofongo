class CommentMailerPreview < ActionMailer::Preview
  def new_comment
    comment = Comment.first
    CommentMailer.with(comment: comment).new_comment
  end

  def new_reply
    reply = Comment.where.not(parent_id: nil).first
    CommentMailer.with(comment: reply).new_comment
  end
end
