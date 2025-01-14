module ImageProcessable
  extend ActiveSupport::Concern

  class_methods do
    def has_optimized_images
      after_create_commit :process_rich_text_images
    end
  end

  private

  def process_rich_text_images
    return unless content.body.present?

    content.body.attachments.each do |attachment|
      next unless attachment.image?

      attachment.blob.variant(
        resize_to_limit: [
          Rails.application.config.blog_image_max_width,
          Rails.application.config.blog_image_max_height
        ],
        strip: true,
        quality: 80,
        interlace: "JPEG",
        sampling_factor: "4:2:0",
        colorspace: "sRGB"
      ).processed
    end
  end
end
