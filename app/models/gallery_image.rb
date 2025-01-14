class GalleryImage < ApplicationRecord
  belongs_to :user
  has_one_attached :image
  
  validates :title, presence: true
  validates :image, presence: true
  validate :acceptable_image
  
  scope :recent, -> { order(created_at: :desc) }
  
  def thumbnail_url
    Rails.application.routes.url_helpers.url_for(
      image.variant(resize_to_limit: [200, 200])
    )
  end
  
  def medium_url
    Rails.application.routes.url_helpers.url_for(
      image.variant(resize_to_limit: [800, 800])
    )
  end
  
  def original_url
    Rails.application.routes.url_helpers.url_for(image)
  end
  
  private
  
  def acceptable_image
    return unless image.attached?
    
    unless image.blob.byte_size <= 10.megabytes
      errors.add(:image, "is too big (should be less than 10MB)")
    end
    
    acceptable_types = ["image/jpeg", "image/png", "image/gif", "image/webp"]
    unless acceptable_types.include?(image.content_type)
      errors.add(:image, "must be a JPEG, PNG, GIF, or WEBP")
    end
  end
end
