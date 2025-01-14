class BlogPostTag < ApplicationRecord
  belongs_to :blog_post
  belongs_to :tag

  validates :blog_post_id, uniqueness: { scope: :tag_id }
end
