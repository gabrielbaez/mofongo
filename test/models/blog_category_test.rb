require 'test_helper'

class BlogCategoryTest < ActiveSupport::TestCase
  def setup
    @category = BlogCategory.new(name: "Test Category")
  end

  test "should be valid" do
    assert @category.valid?
  end

  test "should require name" do
    @category.name = ""
    assert_not @category.valid?
  end

  test "should have unique name" do
    @category.save!
    duplicate = BlogCategory.new(name: @category.name)
    assert_not duplicate.valid?
  end

  test "should generate slug from name" do
    @category.name = "Test Category Name"
    @category.save!
    assert_equal "test-category-name", @category.slug
  end

  test "should handle special characters in slug" do
    @category.name = "Test & Category! @ Name"
    @category.save!
    assert_equal "test-category-name", @category.slug
  end

  test "should ensure unique slug" do
    @category.save!
    duplicate = BlogCategory.new(name: "Test Category")
    duplicate.save!
    assert_not_equal @category.slug, duplicate.slug
  end

  test "should update slug when name changes" do
    @category.save!
    original_slug = @category.slug
    @category.update(name: "New Category Name")
    assert_not_equal original_slug, @category.slug
    assert_equal "new-category-name", @category.slug
  end
end
