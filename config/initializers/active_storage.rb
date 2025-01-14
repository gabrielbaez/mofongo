Rails.application.configure do
  config.active_storage.variant_processor = :mini_magick
  
  # Add custom variants
  config.active_storage.service_urls_expire_in = 1.hour
  
  # Configure maximum dimensions for blog images
  config.blog_image_max_width = 1200
  config.blog_image_max_height = 800
end
