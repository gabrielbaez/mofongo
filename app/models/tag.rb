class Tag < ApplicationRecord
  has_many :blog_post_tags, dependent: :destroy
  has_many :blog_posts, through: :blog_post_tags

  validates :name, presence: true, uniqueness: { case_sensitive: false }
  validates :slug, presence: true, uniqueness: true

  before_validation :generate_slug, if: :name_changed?

  private

  def generate_slug
    self.slug = name.to_s.parameterize
  end
end
