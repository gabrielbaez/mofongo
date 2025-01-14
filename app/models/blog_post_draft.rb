class BlogPostDraft < ApplicationRecord
  belongs_to :user
  belongs_to :blog_post, optional: true
  
  validates :title, presence: true
  validates :content, presence: true
  validates :user_id, presence: true
  
  before_save :set_last_edited_at
  
  def self.find_or_initialize_for(blog_post)
    where(blog_post_id: blog_post.id).first_or_initialize do |draft|
      draft.title = blog_post.title
      draft.content = blog_post.content
      draft.summary = blog_post.summary
      draft.tag_list = blog_post.tag_list
      draft.blog_series_id = blog_post.blog_series_id
      draft.user = blog_post.user
    end
  end
  
  private
  
  def set_last_edited_at
    self.last_edited_at = Time.current
  end
end
