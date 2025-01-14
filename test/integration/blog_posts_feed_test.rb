require 'test_helper'
require 'nokogiri'

class BlogPostsFeedTest < ActionDispatch::IntegrationTest
  def setup
    @user = users(:one)
    @blog_post = blog_posts(:one)
    # Ensure the blog post is published
    @blog_post.update!(published: true, published_at: 1.day.ago)
  end

  test "should get RSS feed" do
    get feed_blog_posts_path(format: :rss)
    assert_response :success
    assert_equal "application/rss+xml", response.media_type
  end

  test "RSS feed should be valid" do
    get feed_blog_posts_path(format: :rss)
    doc = Nokogiri::XML(response.body)
    
    # Check RSS version
    assert_equal "2.0", doc.at_xpath("/rss")["version"]
    
    # Check required channel elements
    channel = doc.at_xpath("/rss/channel")
    assert_not_nil channel.at_xpath("title")
    assert_not_nil channel.at_xpath("link")
    assert_not_nil channel.at_xpath("description")
    
    # Check optional but important channel elements
    assert_not_nil channel.at_xpath("language")
    assert_not_nil channel.at_xpath("lastBuildDate")
    assert_not_nil channel.at_xpath("atom:link[@rel='self']")
    
    # Check image element
    image = channel.at_xpath("image")
    assert_not_nil image
    assert_not_nil image.at_xpath("url")
    assert_not_nil image.at_xpath("title")
    assert_not_nil image.at_xpath("link")
  end

  test "RSS feed should include published blog posts" do
    get feed_blog_posts_path(format: :rss)
    doc = Nokogiri::XML(response.body)
    
    # Find the item for our test blog post
    item = doc.at_xpath("//item[guid='#{blog_post_url(@blog_post)}']")
    assert_not_nil item
    
    # Check required item elements
    assert_equal @blog_post.title, item.at_xpath("title").text
    assert_equal blog_post_url(@blog_post), item.at_xpath("link").text
    assert_not_nil item.at_xpath("description")
    
    # Check optional but important item elements
    assert_equal @blog_post.user.email, item.at_xpath("author").text
    assert_equal @blog_post.published_at.to_fs(:rfc822), item.at_xpath("pubDate").text
  end

  test "RSS feed should not include unpublished posts" do
    @blog_post.update!(published: false)
    get feed_blog_posts_path(format: :rss)
    doc = Nokogiri::XML(response.body)
    
    # Should not find the unpublished post
    item = doc.at_xpath("//item[guid='#{blog_post_url(@blog_post)}']")
    assert_nil item
  end

  test "RSS feed should include post tags as categories" do
    tag = Tag.create!(name: "Test Tag")
    @blog_post.tags << tag
    
    get feed_blog_posts_path(format: :rss)
    doc = Nokogiri::XML(response.body)
    
    item = doc.at_xpath("//item[guid='#{blog_post_url(@blog_post)}']")
    assert_not_nil item
    
    category = item.at_xpath("category[text()='#{tag.name}']")
    assert_not_nil category
  end
end
