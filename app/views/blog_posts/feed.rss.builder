xml.instruct! :xml, version: "1.0"
xml.rss version: "2.0",
        "xmlns:atom" => "http://www.w3.org/2005/Atom",
        "xmlns:content" => "http://purl.org/rss/1.0/modules/content/",
        "xmlns:dc" => "http://purl.org/dc/elements/1.1/",
        "xmlns:media" => "http://search.yahoo.com/mrss/" do
  xml.channel do
    # Required channel elements
    xml.title "Mofongo Blog"
    xml.link root_url
    xml.description "Discover insightful articles on software development, technology, and more."
    
    # Optional channel elements
    xml.language "en-US"
    xml.copyright " #{Time.current.year} Mofongo. All rights reserved."
    xml.managingEditor "editor@mofongo.com"
    xml.webMaster "webmaster@mofongo.com"
    xml.category "Technology"
    xml.category "Software Development"
    xml.generator "Mofongo Blog Engine"
    xml.lastBuildDate Time.current.to_fs(:rfc822)
    xml.ttl "60"
    
    # RSS autodiscovery
    xml.tag! "atom:link",
            href: feed_blog_posts_url(format: :rss),
            rel: "self",
            type: "application/rss+xml"
    
    # Channel image
    xml.image do
      xml.url asset_url("logo.png")
      xml.title "Mofongo Blog"
      xml.link root_url
    end

    @blog_posts.each do |post|
      xml.item do
        # Required item elements
        xml.title post.title
        xml.link blog_post_url(post)
        xml.description post.summary
        
        # Optional item elements
        xml.author post.user.email
        xml.pubDate post.published_at.to_fs(:rfc822)
        xml.guid blog_post_url(post), isPermaLink: "true"
        
        # Categories (tags)
        post.tags.each do |tag|
          xml.category tag.name
        end
        
        # Full content with CDATA
        xml.tag!("content:encoded") do
          xml.cdata! render(
            partial: "blog_posts/content",
            formats: [:html],
            locals: { post: post }
          )
        end
        
        # Dublin Core metadata
        xml.tag!("dc:creator", post.user.display_name)
        xml.tag!("dc:date", post.published_at.iso8601)
        
        # Media content (if featured image exists)
        if post.featured_image.attached?
          xml.tag!("media:content",
                  url: url_for(post.featured_image),
                  type: post.featured_image.content_type,
                  medium: "image")
          
          xml.tag!("media:thumbnail",
                  url: url_for(post.featured_image.variant(resize_to_limit: [300, 300])))
        end
        
        # Reading time
        xml.tag!("mofongo:readingTime",
                xmlns: "http://mofongo.com/ns/1.0",
                minutes: post.estimated_reading_time)
      end
    end
  end
end
