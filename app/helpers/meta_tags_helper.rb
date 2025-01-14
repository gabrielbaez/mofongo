module MetaTagsHelper
  def meta_title
    content_for(:meta_title) || default_meta_title
  end
  
  def meta_description
    content_for(:meta_description) || default_meta_description
  end
  
  def meta_type
    content_for(:meta_type) || 'website'
  end
  
  def meta_image
    content_for(:meta_image) || asset_url('default-og-image.png')
  end
  
  def meta_published_time
    content_for(:meta_published_time)
  end
  
  def meta_author
    content_for(:meta_author)
  end
  
  def meta_tags
    content_for(:meta_tags)
  end
  
  def meta_canonical
    content_for(:meta_canonical) || request.original_url.split('?').first
  end
  
  private
  
  def default_meta_title
    "Mofongo - Share Your Knowledge"
  end
  
  def default_meta_description
    "Join our community of writers and readers. Share your knowledge, discover new perspectives, and engage in meaningful discussions."
  end
end
