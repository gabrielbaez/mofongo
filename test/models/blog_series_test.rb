require 'test_helper'

class BlogSeriesTest < ActiveSupport::TestCase
  def setup
    @user = users(:one)
    @series = BlogSeries.new(
      title: "Test Series",
      description: "Test description",
      user: @user
    )
  end

  test "should be valid" do
    assert @series.valid?
  end

  test "should require title" do
    @series.title = ""
    assert_not @series.valid?
  end

  test "should require user" do
    @series.user = nil
    assert_not @series.valid?
  end

  test "should generate slug from title" do
    @series.title = "Test Series Title"
    @series.save!
    assert_equal "test-series-title", @series.slug
  end

  test "should ensure unique slug" do
    @series.save!
    duplicate = BlogSeries.new(
      title: "Test Series",
      description: "Another description",
      user: @user
    )
    duplicate.save!
    assert_not_equal @series.slug, duplicate.slug
  end

  test "should update slug when title changes" do
    @series.save!
    original_slug = @series.slug
    @series.update(title: "New Series Title")
    assert_not_equal original_slug, @series.slug
    assert_equal "new-series-title", @series.slug
  end

  test "should use slug for param" do
    @series.save!
    assert_equal @series.slug, @series.to_param
  end

  test "should order blog posts by position" do
    @series.save!
    second_post = BlogPost.create!(
      title: "Second Post",
      content: "Content",
      summary: "Summary",
      user: @user,
      blog_category: blog_categories(:one),
      blog_series: @series,
      position: 2
    )
    first_post = BlogPost.create!(
      title: "First Post",
      content: "Content",
      summary: "Summary",
      user: @user,
      blog_category: blog_categories(:one),
      blog_series: @series,
      position: 1
    )
    
    assert_equal [first_post, second_post], @series.blog_posts.to_a
  end

  test "should only count published posts in total_posts" do
    @series.save!
    BlogPost.create!(
      title: "Published Post",
      content: "Content",
      summary: "Summary",
      user: @user,
      blog_category: blog_categories(:one),
      blog_series: @series,
      published: true
    )
    BlogPost.create!(
      title: "Draft Post",
      content: "Content",
      summary: "Summary",
      user: @user,
      blog_category: blog_categories(:one),
      blog_series: @series,
      published: false
    )
    
    assert_equal 1, @series.total_posts
  end

  test "should calculate total reading time" do
    @series.save!
    # Create posts with specific word counts
    BlogPost.create!(
      title: "Post 1",
      content: "word " * 200,  # 200 words = 1 minute
      summary: "Summary",
      user: @user,
      blog_category: blog_categories(:one),
      blog_series: @series,
      published: true
    )
    BlogPost.create!(
      title: "Post 2",
      content: "word " * 400,  # 400 words = 2 minutes
      summary: "Summary",
      user: @user,
      blog_category: blog_categories(:one),
      blog_series: @series,
      published: true
    )
    
    assert_equal 3, @series.reading_time.round
  end

  test "should nullify blog_series_id in posts when series is destroyed" do
    @series.save!
    post = BlogPost.create!(
      title: "Test Post",
      content: "Content",
      summary: "Summary",
      user: @user,
      blog_category: blog_categories(:one),
      blog_series: @series
    )
    
    @series.destroy
    assert_nil post.reload.blog_series_id
  end
end
