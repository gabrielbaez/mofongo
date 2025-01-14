class User < ApplicationRecord
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable, :trackable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :validatable,
         :trackable, :confirmable, authentication_keys: [:username]

  # Define roles enum
  enum :role_id, { user: 0, moderator: 1, administrator: 2 }

  # Role convenience methods
  def administrator!
    update!(role_id: :administrator)
  end

  def user!
    update!(role_id: :user)
  end

  def moderator!
    update!(role_id: :moderator)
  end

  has_many :blog_posts, dependent: :destroy
  has_many :blog_series, dependent: :destroy
  has_many :blog_post_drafts, dependent: :destroy
  has_many :comments, dependent: :destroy
  has_many :likes, class_name: 'BlogPostLike', dependent: :destroy
  has_many :gallery_images, dependent: :destroy
  has_many :user_achievements, dependent: :destroy
  has_many :achievements, through: :user_achievements

  has_one_attached :avatar

  has_many :votes, dependent: :destroy
  has_one :subscription, dependent: :nullify

  # Achievements
  # has_many :user_achievements, dependent: :destroy
  # has_many :achievements, through: :user_achievements

  # Following relationships
  has_many :active_follows, class_name: 'Follow',
                           foreign_key: 'follower_id',
                           dependent: :destroy
  has_many :passive_follows, class_name: 'Follow',
                            foreign_key: 'followed_id',
                            dependent: :destroy
  has_many :following, through: :active_follows, source: :followed
  has_many :followers, through: :passive_follows, source: :follower

  # Notifications
  has_many :notifications, foreign_key: :recipient_id, dependent: :destroy

  validates :username, presence: true,
                      uniqueness: { case_sensitive: false },
                      format: { with: /\A[a-zA-Z0-9_-]+\z/ },
                      length: { in: 3..30 }
  validates :name, presence: true
  validates :email, presence: true, uniqueness: { case_sensitive: false }
  validates :terms_of_service, acceptance: true, on: :create

  before_validation :set_username, on: :create
  before_save :downcase_email

  def display_name
    username
  end

  def recent_comments(limit = 10)
    comments.includes(:blog_post)
           .order(created_at: :desc)
           .limit(limit)
  end

  def recent_blog_posts(limit = 5)
    blog_posts.published
             .order(published_at: :desc)
             .limit(limit)
  end

  def comment_stats
    {
      total_comments: comments.count,
      total_score: comments.sum(:score),
      avg_score: comments.average(:score)&.round(1) || 0
    }
  end

  def to_param
    username
  end

  def total_points
    achievements.sum(:points)
  end

  def check_achievements
    Achievement.check_achievements_for(self)
  end

  def follow(other_user)
    return if self == other_user
    following << other_user
    Notification.notify(
      recipient: other_user,
      actor: self,
      action: 'started_following',
      notifiable: self
    )
  end

  def unfollow(other_user)
    following.delete(other_user)
  end

  def following?(other_user)
    following.include?(other_user)
  end

  def feed
    following_ids = "SELECT followed_id FROM follows WHERE follower_id = :user_id"
    BlogPost.where("user_id IN (#{following_ids}) OR user_id = :user_id",
                  user_id: id)
           .published
           .includes(:user, :blog_category, :tags)
           .order(published_at: :desc)
  end

  def unread_notifications_count
    notifications.unread.count
  end

  private

  def set_username
    return if username.present?

    base = email.split('@').first.gsub(/[^a-zA-Z0-9_-]/, '')
    self.username = base

    # If username is taken, append numbers until we find a unique one
    counter = 1
    while User.exists?(username: username)
      self.username = "#{base}#{counter}"
      counter += 1
    end
  end

  def downcase_email
    self.email = email.downcase if email.present?
  end

  def role_display
    role_id.to_s.titleize
  end

  def admin?
    administrator?
  end

  def moderator_or_admin?
    moderator? || administrator?
  end

  def self.states
    [
      ['Alabama', 'AL'],
      ['Alaska', 'AK'],
      ['Arizona', 'AZ'],
      ['Arkansas', 'AR'],
      ['California', 'CA'],
      ['Colorado', 'CO'],
      ['Connecticut', 'CT'],
      ['Delaware', 'DE'],
      ['Florida', 'FL'],
      ['Georgia', 'GA'],
      ['Hawaii', 'HI'],
      ['Idaho', 'ID'],
      ['Illinois', 'IL'],
      ['Indiana', 'IN'],
      ['Iowa', 'IA'],
      ['Kansas', 'KS'],
      ['Kentucky', 'KY'],
      ['Louisiana', 'LA'],
      ['Maine', 'ME'],
      ['Maryland', 'MD'],
      ['Massachusetts', 'MA'],
      ['Michigan', 'MI'],
      ['Minnesota', 'MN'],
      ['Mississippi', 'MS'],
      ['Missouri', 'MO'],
      ['Montana', 'MT'],
      ['Nebraska', 'NE'],
      ['Nevada', 'NV'],
      ['New Hampshire', 'NH'],
      ['New Jersey', 'NJ'],
      ['New Mexico', 'NM'],
      ['New York', 'NY'],
      ['North Carolina', 'NC'],
      ['North Dakota', 'ND'],
      ['Ohio', 'OH'],
      ['Oklahoma', 'OK'],
      ['Oregon', 'OR'],
      ['Pennsylvania', 'PA'],
      ['Rhode Island', 'RI'],
      ['South Carolina', 'SC'],
      ['South Dakota', 'SD'],
      ['Tennessee', 'TN'],
      ['Texas', 'TX'],
      ['Utah', 'UT'],
      ['Vermont', 'VT'],
      ['Virginia', 'VA'],
      ['Washington', 'WA'],
      ['West Virginia', 'WV'],
      ['Wisconsin', 'WI'],
      ['Wyoming', 'WY']
    ]
  end

  # Allow authentication with either username or email
  def self.find_first_by_auth_conditions(warden_conditions)
    conditions = warden_conditions.dup
    if login = conditions.delete(:login)
      where(conditions).where(["lower(username) = :value OR lower(email) = :value", { value: login.downcase }]).first
    else
      where(conditions).first
    end
  end
end
