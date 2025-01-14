class Comment < ApplicationRecord
  belongs_to :blog_post
  belongs_to :user
  belongs_to :parent, class_name: 'Comment', optional: true
  has_many :replies, class_name: 'Comment', foreign_key: 'parent_id', dependent: :destroy
  has_many :votes, dependent: :destroy
  
  validates :content, presence: true
  validates :user_id, presence: true
  
  scope :root_comments, -> { where(parent_id: nil) }
  scope :recent_first, -> { order(created_at: :desc) }
  scope :by_score, -> { order(score: :desc) }
  
  after_create :auto_approve
  after_create :send_notification
  
  def vote_by(user)
    votes.find_by(user: user)
  end
  
  def voted_by?(user)
    votes.exists?(user: user)
  end
  
  def upvoted_by?(user)
    votes.exists?(user: user, value: 1)
  end
  
  def downvoted_by?(user)
    votes.exists?(user: user, value: -1)
  end
  
  def update_score
    update_columns(
      upvotes_count: votes.where(value: 1).count,
      downvotes_count: votes.where(value: -1).count,
      score: votes.sum(:value)
    )
  end
  
  private
  
  def auto_approve
    update_columns(approved: true, approved_at: Time.current)
  end

  def send_notification
    # Don't notify if the commenter is the post author or parent comment author
    return if user_id == blog_post.user_id
    return if parent && user_id == parent.user_id

    CommentMailer.with(comment: self).new_comment.deliver_later
  end
end
