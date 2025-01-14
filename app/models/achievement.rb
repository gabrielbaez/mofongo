class Achievement < ApplicationRecord
  has_many :user_achievements, dependent: :destroy
  has_many :users, through: :user_achievements
  has_many :achievement_progresses, dependent: :destroy
  
  validates :name, presence: true, uniqueness: true
  validates :description, presence: true
  validates :badge_icon, presence: true
  validates :points, presence: true, numericality: { only_integer: true, greater_than_or_equal_to: 0 }
  validates :category, presence: true
  
  # Achievement categories
  CATEGORIES = {
    commenting: 'Commenting',
    posting: 'Posting',
    engagement: 'Engagement',
    reputation: 'Reputation'
  }.freeze
  
  validates :category, inclusion: { in: CATEGORIES.keys.map(&:to_s) }
  
  # Scopes for different achievement types
  scope :commenting, -> { where(category: 'commenting') }
  scope :posting, -> { where(category: 'posting') }
  scope :engagement, -> { where(category: 'engagement') }
  scope :reputation, -> { where(category: 'reputation') }
  
  def self.check_achievements_for(user)
    check_comment_achievements(user)
    check_post_achievements(user)
    check_engagement_achievements(user)
    check_reputation_achievements(user)
  end
  
  def progress_for(user)
    achievement_progresses.find_or_create_by(user: user) do |progress|
      progress.target_value = threshold_for(name)
    end
  end
  
  private
  
  def self.check_comment_achievements(user)
    comment_count = user.comments.count
    update_progress(user, 'commenting', comment_count)
    
    {
      'First Comment' => 1,
      'Active Commenter' => 10,
      'Comment Expert' => 50,
      'Comment Master' => 100
    }.each do |name, threshold|
      if comment_count >= threshold
        achievement = find_by(name: name)
        unless user.achievements.include?(achievement)
          user.achievements << achievement
          notify_achievement(user, achievement)
        end
      end
    end
  end
  
  def self.check_post_achievements(user)
    post_count = user.blog_posts.published.count
    update_progress(user, 'posting', post_count)
    
    {
      'First Post' => 1,
      'Regular Blogger' => 5,
      'Prolific Writer' => 20,
      'Blog Master' => 50
    }.each do |name, threshold|
      if post_count >= threshold
        achievement = find_by(name: name)
        unless user.achievements.include?(achievement)
          user.achievements << achievement
          notify_achievement(user, achievement)
        end
      end
    end
  end
  
  def self.check_engagement_achievements(user)
    total_votes = user.votes.count
    update_progress(user, 'engagement', total_votes)
    
    {
      'First Vote' => 1,
      'Active Voter' => 10,
      'Super Voter' => 50,
      'Vote Master' => 100
    }.each do |name, threshold|
      if total_votes >= threshold
        achievement = find_by(name: name)
        unless user.achievements.include?(achievement)
          user.achievements << achievement
          notify_achievement(user, achievement)
        end
      end
    end
  end
  
  def self.check_reputation_achievements(user)
    total_score = user.comments.sum(:score)
    update_progress(user, 'reputation', total_score)
    
    {
      'Rising Star' => 10,
      'Community Favorite' => 50,
      'Top Contributor' => 200,
      'Legend' => 1000
    }.each do |name, threshold|
      if total_score >= threshold
        achievement = find_by(name: name)
        unless user.achievements.include?(achievement)
          user.achievements << achievement
          notify_achievement(user, achievement)
        end
      end
    end
  end
  
  def self.notify_achievement(user, achievement)
    Notification.notify(
      recipient: user,
      action: 'achievement_unlocked',
      notifiable: achievement
    )
  end
  
  def self.update_progress(user, category, current_value)
    where(category: category).find_each do |achievement|
      progress = achievement.progress_for(user)
      progress.update(
        current_value: current_value,
        last_updated_at: Time.current
      )
    end
  end
  
  def threshold_for(name)
    case name
    when 'First Comment', 'First Post', 'First Vote'
      1
    when 'Active Commenter', 'Active Voter'
      10
    when 'Regular Blogger'
      5
    when 'Comment Expert', 'Super Voter'
      50
    when 'Prolific Writer'
      20
    when 'Comment Master', 'Vote Master', 'Blog Master'
      100
    when 'Rising Star'
      10
    when 'Community Favorite'
      50
    when 'Top Contributor'
      200
    when 'Legend'
      1000
    else
      100 # default threshold
    end
  end
end
