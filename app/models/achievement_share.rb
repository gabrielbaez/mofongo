class AchievementShare < ApplicationRecord
  belongs_to :user_achievement
  has_one :user, through: :user_achievement
  has_one :achievement, through: :user_achievement
  
  validates :message, length: { maximum: 280 }
  
  after_create_commit :broadcast_to_feed
  
  def self.recent
    includes(:user, :achievement)
      .order(created_at: :desc)
      .limit(10)
  end
  
  private
  
  def broadcast_to_feed
    broadcast_prepend_later_to(
      :achievement_shares,
      target: 'achievement-shares-feed',
      partial: 'achievement_shares/achievement_share'
    )
  end
end
