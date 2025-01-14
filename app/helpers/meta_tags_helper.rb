module MetaTagsHelper
  def meta_title
    @meta_title || default_meta_title
  end
  
  def meta_description
    @meta_description || default_meta_description
  end
  
  def meta_type
    @meta_type || 'website'
  end
  
  def meta_image
    @meta_image
  end
  
  def meta_published_time
    @meta_published_time
  end
  
  def meta_author
    @meta_author
  end
  
  def meta_tags
    @meta_tags
  end
  
  def meta_canonical
    @meta_canonical || request.original_url.split('?').first
  end
  
  private
  
  def default_meta_title
    "Mofongo - Share Your Knowledge"
  end
  
  def default_meta_description
    "A platform for sharing knowledge and connecting with like-minded individuals."
  end
end
