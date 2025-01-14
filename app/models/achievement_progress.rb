class AchievementProgress < ApplicationRecord
  belongs_to :user
  belongs_to :achievement
  
  validates :user_id, uniqueness: { scope: :achievement_id }
  validates :current_value, presence: true, numericality: { only_integer: true, greater_than_or_equal_to: 0 }
  validates :target_value, presence: true, numericality: { only_integer: true, greater_than: 0 }
  
  def percentage
    [(current_value.to_f / target_value * 100).round, 100].min
  end
  
  def completed?
    current_value >= target_value
  end
  
  def remaining
    [target_value - current_value, 0].max
  end
end
