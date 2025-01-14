class Follow < ApplicationRecord
  belongs_to :follower, class_name: 'User'
  belongs_to :followed, class_name: 'User'
  
  validates :follower_id, presence: true
  validates :followed_id, presence: true
  validates :follower_id, uniqueness: { scope: :followed_id }
  validate :cannot_follow_self
  
  after_create :notify_followed_user
  
  private
  
  def cannot_follow_self
    if follower_id == followed_id
      errors.add(:follower_id, "can't follow yourself")
    end
  end
  
  def notify_followed_user
    FollowMailer.with(follow: self).new_follower.deliver_later
  end
end