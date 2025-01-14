require 'test_helper'

class TagTest < ActiveSupport::TestCase
  def setup
    @tag = Tag.new(name: "Test Tag")
  end

  test "should be valid" do
    assert @tag.valid?
  end

  test "should require name" do
    @tag.name = ""
    assert_not @tag.valid?
  end

  test "should have unique name case-insensitive" do
    @tag.save!
    duplicate = Tag.new(name: @tag.name.upcase)
    assert_not duplicate.valid?
  end

  test "should generate slug from name" do
    @tag.name = "Test Tag Name"
    @tag.save!
    assert_equal "test-tag-name", @tag.slug
  end

  test "should handle special characters in slug" do
    @tag.name = "Test & Tag! @ Name"
    @tag.save!
    assert_equal "test-tag-name", @tag.slug
  end

  test "should ensure unique slug" do
    @tag.save!
    duplicate = Tag.new(name: "Test Tag")
    duplicate.save!
    assert_not_equal @tag.slug, duplicate.slug
  end

  test "should update slug when name changes" do
    @tag.save!
    original_slug = @tag.slug
    @tag.update(name: "New Tag Name")
    assert_not_equal original_slug, @tag.slug
    assert_equal "new-tag-name", @tag.slug
  end

  test "should destroy dependent blog_post_tags" do
    @tag.save!
    blog_post = blog_posts(:one)
    blog_post_tag = BlogPostTag.create!(blog_post: blog_post, tag: @tag)
    
    assert_difference 'BlogPostTag.count', -1 do
      @tag.destroy
    end
  end
end
