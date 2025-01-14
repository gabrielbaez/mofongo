require 'test_helper'

class BlogPostTest < ActiveSupport::TestCase
  def setup
    @user = users(:one)
    @category = blog_categories(:one)
    @blog_post = BlogPost.new(
      title: "Test Post",
      content: "Test content",
      summary: "Test summary",
      user: @user,
      blog_category: @category
    )
  end

  test "should be valid" do
    assert @blog_post.valid?
  end

  test "should require title" do
    @blog_post.title = ""
    assert_not @blog_post.valid?
  end

  test "should require content" do
    @blog_post.content = ""
    assert_not @blog_post.valid?
  end

  test "should require summary" do
    @blog_post.summary = ""
    assert_not @blog_post.valid?
  end

  test "should generate unique slug" do
    @blog_post.save
    assert_not_nil @blog_post.slug
    
    duplicate = @blog_post.dup
    duplicate.save
    assert_not_equal @blog_post.slug, duplicate.slug
  end

  test "should validate position uniqueness within series" do
    series = blog_series(:one)
    @blog_post.blog_series = series
    @blog_post.position = 1
    @blog_post.save!
    
    duplicate = BlogPost.new(
      title: "Another Post",
      content: "Content",
      summary: "Summary",
      user: @user,
      blog_category: @category,
      blog_series: series,
      position: 1
    )
    assert_not duplicate.valid?
    
    duplicate.position = 2
    assert duplicate.valid?
  end

  test "scopes should filter correctly" do
    @blog_post.save!
    published_post = BlogPost.create!(
      title: "Published Post",
      content: "Content",
      summary: "Summary",
      user: @user,
      blog_category: @category,
      published: true
    )
    featured_post = BlogPost.create!(
      title: "Featured Post",
      content: "Content",
      summary: "Summary",
      user: @user,
      blog_category: @category,
      published: true,
      featured: true
    )

    assert_includes BlogPost.published, published_post
    assert_not_includes BlogPost.published, @blog_post
    assert_includes BlogPost.draft, @blog_post
    assert_includes BlogPost.featured, featured_post
  end

  test "date scopes should filter correctly" do
    post = BlogPost.create!(
      title: "Date Test Post",
      content: "Content",
      summary: "Summary",
      user: @user,
      blog_category: @category,
      published: true,
      published_at: Time.new(2025, 1, 15)
    )

    assert_includes BlogPost.by_year(2025), post
    assert_includes BlogPost.by_month(2025, 1), post
    assert_includes BlogPost.by_date(2025, 1, 15), post
  end

  test "search scope should find posts" do
    post = BlogPost.create!(
      title: "Unique Search Title",
      content: "Unique search content",
      summary: "Summary",
      user: @user,
      blog_category: @category
    )
    
    results = BlogPost.search("Unique")
    assert_includes results, post
  end

  test "should set published_at when published" do
    @blog_post.save!
    assert_nil @blog_post.published_at
    
    @blog_post.update(published: true)
    assert_not_nil @blog_post.published_at
  end

  test "should calculate reading time" do
    @blog_post.content = "word " * 1000  # 1000 words
    @blog_post.save!
    
    # Assuming 200 words per minute
    assert_equal 5, @blog_post.reading_time
  end

  test "should find related posts" do
    @blog_post.save!
    tag = Tag.create!(name: "Test Tag")
    @blog_post.tags << tag
    
    related_post = BlogPost.create!(
      title: "Related Post",
      content: "Content",
      summary: "Summary",
      user: @user,
      blog_category: @category,
      published: true
    )
    related_post.tags << tag
    
    unrelated_post = BlogPost.create!(
      title: "Unrelated Post",
      content: "Content",
      summary: "Summary",
      user: @user,
      blog_category: @category,
      published: true
    )
    
    related = @blog_post.related_posts
    assert_includes related, related_post
    assert_not_includes related, unrelated_post
  end

  test "should find next and previous posts in series" do
    series = blog_series(:one)
    first_post = BlogPost.create!(
      title: "First Post",
      content: "Content",
      summary: "Summary",
      user: @user,
      blog_category: @category,
      blog_series: series,
      position: 1,
      published: true,
      published_at: 1.day.ago
    )
    
    second_post = BlogPost.create!(
      title: "Second Post",
      content: "Content",
      summary: "Summary",
      user: @user,
      blog_category: @category,
      blog_series: series,
      position: 2,
      published: true,
      published_at: Time.current
    )
    
    third_post = BlogPost.create!(
      title: "Third Post",
      content: "Content",
      summary: "Summary",
      user: @user,
      blog_category: @category,
      blog_series: series,
      position: 3,
      published: true,
      published_at: 1.day.from_now
    )
    
    assert_equal second_post.next_post, third_post
    assert_equal second_post.previous_post, first_post
    assert_nil first_post.previous_post
    assert_nil third_post.next_post
  end

  test "should notify subscribers when published" do
    subscriber = users(:two)
    subscription = Subscription.create!(user: subscriber)
    
    assert_enqueued_with(job: NotifySubscribersJob) do
      @blog_post.update(published: true)
    end
  end

  test "should update series post count" do
    series = blog_series(:one)
    initial_count = series.post_count
    
    @blog_post.update(blog_series: series)
    assert_equal initial_count + 1, series.reload.post_count
    
    @blog_post.update(blog_series: nil)
    assert_equal initial_count, series.reload.post_count
  end
end
