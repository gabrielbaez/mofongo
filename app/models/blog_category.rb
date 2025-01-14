class BlogCategory < ApplicationRecord
  has_many :blog_posts
  
  validates :name, presence: true, uniqueness: true
  validates :slug, presence: true, uniqueness: true
  
  before_validation :generate_slug, if: :name_changed?
  
  private
  
  def generate_slug
    self.slug = name.to_s.parameterize
  end
end
