class BlogPost < ApplicationRecord
  include ImageProcessable
  
  belongs_to :user
  belongs_to :blog_category
  belongs_to :blog_series, optional: true
  has_many :blog_post_tags, dependent: :destroy
  has_many :tags, through: :blog_post_tags
  has_many :comments, dependent: :destroy
  has_many :likes, dependent: :destroy
  has_many :taggings, dependent: :destroy
  
  has_rich_text :content
  has_one_attached :featured_image
  has_optimized_images
  
  validates :title, presence: true
  validates :slug, presence: true, uniqueness: true
  validates :position, numericality: { only_integer: true }, 
                      allow_nil: true,
                      uniqueness: { scope: :blog_series_id }, 
                      if: :blog_series_id?
  validates :content, presence: true
  validates :summary, presence: true
  
  scope :published, -> { where(published: true) }
  scope :draft, -> { where(published: false) }
  scope :featured, -> { where(featured: true) }
  scope :recent, -> { order(published_at: :desc) }
  
  scope :by_year, ->(year) { where('EXTRACT(YEAR FROM published_at) = ?', year) }
  scope :by_month, ->(year, month) { where('EXTRACT(YEAR FROM published_at) = ? AND EXTRACT(MONTH FROM published_at) = ?', year, month) }
  scope :by_date, ->(year, month, day) { where('EXTRACT(YEAR FROM published_at) = ? AND EXTRACT(MONTH FROM published_at) = ? AND EXTRACT(DAY FROM published_at) = ?', year, month, day) }
  
  scope :in_series_order, -> { order(position: :asc) }
  
  scope :search, ->(query) {
    joins("LEFT JOIN action_text_rich_texts ON action_text_rich_texts.record_id = blog_posts.id AND action_text_rich_texts.record_type = 'BlogPost'")
    .joins("LEFT JOIN blog_post_tags ON blog_post_tags.blog_post_id = blog_posts.id")
    .joins("LEFT JOIN tags ON tags.id = blog_post_tags.tag_id")
    .where("blog_posts.title ILIKE :query OR action_text_rich_texts.body ILIKE :query OR tags.name ILIKE :query", query: "%#{query}%")
    .distinct
  }
  
  before_validation :generate_slug, if: :title_changed?
  before_validation :set_published_at, if: :published_changed?
  before_save :sanitize_content
  before_save :calculate_reading_time
  after_save :notify_subscribers, if: -> { saved_change_to_published? && published? }
  after_save :update_series_post_count, if: :saved_change_to_blog_series_id?
  
  def published?
    published_at.present?
  end
  
  def publish!
    touch(:published_at) unless published?
  end
  
  def unpublish!
    update(published_at: nil)
  end
  
  def reading_time
    words_per_minute = 200
    word_count = content.to_s.split.size
    minutes = (word_count / words_per_minute).ceil
    minutes = 1 if minutes.zero?
    minutes
  end
  
  def related_posts(limit: 3)
    return [] unless published?
    
    tag_ids = tags.pluck(:id)
    return [] if tag_ids.empty?
    
    BlogPost.published
           .joins(:taggings)
           .where.not(id: id)
           .where(taggings: { tag_id: tag_ids })
           .group('blog_posts.id')
           .select('blog_posts.*, COUNT(taggings.tag_id) as matches')
           .order('matches DESC, published_at DESC')
           .limit(limit)
  end
  
  def next_post
    return nil unless blog_series_id?
    
    BlogPost.published
           .where(blog_series_id: blog_series_id)
           .where('published_at > ?', published_at)
           .order(published_at: :asc)
           .first
  end
  
  def previous_post
    return nil unless blog_series_id?
    
    BlogPost.published
           .where(blog_series_id: blog_series_id)
           .where('published_at < ?', published_at)
           .order(published_at: :desc)
           .first
  end
  
  def next_in_series
    return nil unless blog_series
    blog_series.blog_posts
              .published
              .where('position > ?', position)
              .order(position: :asc)
              .first
  end

  def prev_in_series
    return nil unless blog_series
    blog_series.blog_posts
              .published
              .where('position < ?', position)
              .order(position: :desc)
              .first
  end
  
  def tag_list
    tags.pluck(:name)
  end
  
  def tag_list=(names)
    self.tags = names.split(',').map(&:strip).map do |name|
      Tag.find_or_create_by!(name: name)
    end
  end
  
  def approved_comments(sort_by = nil)
    comments = self.comments.root_comments.includes(:user, :replies)
    
    case sort_by
    when 'newest'
      comments.order(created_at: :desc)
    when 'oldest'
      comments.order(created_at: :asc)
    when 'top'
      comments.order(score: :desc, created_at: :desc)
    when 'controversial'
      comments.order('(upvotes_count + downvotes_count) DESC, created_at DESC')
    else
      # Default to 'top' sorting if no valid sort option is provided
      comments.order(score: :desc, created_at: :desc)
    end
  end

  def comment_count
    comments.where(approved: true).count
  end
  
  private
  
  def generate_slug
    self.slug = title.to_s.parameterize
  end
  
  def set_published_at
    self.published_at = Time.current if published?
  end
  
  def sanitize_content
    self.content = Rails::Html::SafeListSanitizer.new.sanitize(
      content,
      tags: %w[p div br strong em u del ins h1 h2 h3 h4 h5 h6 ul ol li blockquote pre code img a table thead tbody tr th td],
      attributes: %w[href src alt title class id style]
    )
  end
  
  def calculate_reading_time
    self.estimated_reading_time = reading_time
  end
  
  def process_tags
    return unless tag_names

    # Convert tag names string to array and clean up
    names = tag_names.split(',').map(&:strip).reject(&:blank?).uniq

    # Find or create tags
    tags_to_assign = names.map do |name|
      Tag.find_or_create_by!(name: name)
    end

    # Update post's tags
    self.tags = tags_to_assign
  end
  
  def notify_subscribers
    Subscription.subscribed
               .by_preference('new_posts')
               .find_each do |subscription|
      SubscriptionMailer.with(
        subscription: subscription,
        blog_post: self
      ).new_post.deliver_later
    end
    
    if blog_series
      Subscription.subscribed
                 .by_preference('series_updates')
                 .find_each do |subscription|
        SubscriptionMailer.with(
          subscription: subscription,
          blog_series: blog_series,
          blog_post: self
        ).series_update.deliver_later
      end
    end
  end
  
  def update_series_post_count
    BlogSeries.where(id: [blog_series_id_before_last_save, blog_series_id])
              .each(&:update_post_count!)
  end
end
