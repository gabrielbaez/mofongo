class UserAchievement < ApplicationRecord
  belongs_to :user
  belongs_to :achievement
  
  validates :user_id, uniqueness: { scope: :achievement_id }
  
  after_create :notify_user
  
  private
  
  def notify_user
    AchievementMailer.with(user_achievement: self).achievement_unlocked.deliver_later
  end
end
