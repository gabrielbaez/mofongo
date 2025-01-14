class BlogSeries < ApplicationRecord
  has_many :blog_posts, -> { order(position: :asc) }, dependent: :nullify
  belongs_to :user
  
  has_rich_text :description
  
  validates :title, presence: true
  validates :slug, presence: true, uniqueness: true
  
  before_validation :generate_slug, if: :title_changed?
  
  def to_param
    slug
  end
  
  def published_posts
    blog_posts.published
  end
  
  def total_posts
    published_posts.count
  end
  
  def reading_time
    published_posts.sum { |post| post.content.to_plain_text.split.size / 200.0 }
  end
  
  private
  
  def generate_slug
    self.slug = title.to_s.parameterize
  end
end
