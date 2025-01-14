atom_feed do |feed|
  feed.title "My Blog"
  feed.subtitle "Latest blog posts from My Blog"
  feed.updated @blog_posts.first.published_at if @blog_posts.any?

  @blog_posts.each do |post|
    feed.entry(post) do |entry|
      entry.title post.title
      entry.content post.content.to_s, type: 'html'
      
      entry.author do |author|
        author.name post.user.email
      end
      
      post.tags.each do |tag|
        entry.category term: tag.name
      end
    end
  end
end
