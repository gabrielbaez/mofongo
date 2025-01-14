class Vote < ApplicationRecord
  belongs_to :user
  belongs_to :comment
  
  validates :user_id, uniqueness: { scope: :comment_id }
  validates :value, inclusion: { in: [-1, 1] }
  
  after_save :update_comment_score
  after_destroy :update_comment_score
  
  private
  
  def update_comment_score
    comment.update_score
  end
end
