class Subscription < ApplicationRecord
  belongs_to :user, optional: true
  
  validates :email, presence: true,
                   uniqueness: { case_sensitive: false },
                   format: { with: URI::MailTo::EMAIL_REGEXP }
  validates :token, presence: true, uniqueness: true
  
  before_validation :set_token, on: :create
  before_create :set_default_preferences
  
  scope :confirmed, -> { where.not(confirmed_at: nil) }
  scope :unconfirmed, -> { where(confirmed_at: nil) }
  scope :subscribed, -> { confirmed.where(unsubscribed_at: nil) }
  scope :by_preference, ->(pref) { where("preferences @> ARRAY[?]", pref) }
  
  PREFERENCES = {
    'weekly_digest' => 'Weekly Blog Digest',
    'new_posts' => 'New Post Notifications',
    'series_updates' => 'Series Updates',
    'community_highlights' => 'Community Highlights'
  }.freeze
  
  def confirm!
    return if confirmed?
    
    update!(confirmed_at: Time.current)
    SubscriptionMailer.welcome_email(self).deliver_later
  end
  
  def confirmed?
    confirmed_at.present?
  end
  
  def unsubscribe!
    update!(unsubscribed_at: Time.current)
  end
  
  def subscribed?
    confirmed? && !unsubscribed_at?
  end
  
  def resubscribe!
    update!(unsubscribed_at: nil)
  end
  
  def preference?(name)
    preferences.include?(name.to_s)
  end
  
  def add_preference(name)
    return if preference?(name)
    preferences << name
    save!
  end
  
  def remove_preference(name)
    return unless preference?(name)
    self.preferences = preferences - [name.to_s]
    save!
  end
  
  def display_name
    name.presence || email.split('@').first
  end
  
  private
  
  def set_token
    self.token = SecureRandom.hex(32)
  end
  
  def set_default_preferences
    self.preferences ||= ['new_posts', 'weekly_digest']
  end
end
