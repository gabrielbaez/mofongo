require 'test_helper'

class GalleryImageTest < ActiveSupport::TestCase
  include ActionDispatch::TestProcess
  
  def setup
    @user = users(:one)
    @gallery_image = GalleryImage.new(
      title: "Test Image",
      user: @user
    )
    # Create a test image file
    @image = fixture_file_upload('test_image.jpg', 'image/jpeg')
    @gallery_image.image.attach(@image)
  end

  test "should be valid" do
    assert @gallery_image.valid?
  end

  test "should require title" do
    @gallery_image.title = ""
    assert_not @gallery_image.valid?
  end

  test "should require user" do
    @gallery_image.user = nil
    assert_not @gallery_image.valid?
  end

  test "should require image" do
    @gallery_image.image = nil
    assert_not @gallery_image.valid?
  end

  test "should validate image size" do
    # Create a large file that exceeds 10MB
    large_file = fixture_file_upload('large_image.jpg', 'image/jpeg')
    def large_file.size; 11.megabytes; end
    
    @gallery_image.image.attach(large_file)
    assert_not @gallery_image.valid?
    assert_includes @gallery_image.errors[:image], "is too big (should be less than 10MB)"
  end

  test "should validate image content type" do
    invalid_file = fixture_file_upload('invalid.txt', 'text/plain')
    @gallery_image.image.attach(invalid_file)
    
    assert_not @gallery_image.valid?
    assert_includes @gallery_image.errors[:image], "must be a JPEG, PNG, GIF, or WEBP"
  end

  test "should accept valid image types" do
    valid_types = {
      'image/jpeg' => 'test.jpg',
      'image/png' => 'test.png',
      'image/gif' => 'test.gif',
      'image/webp' => 'test.webp'
    }
    
    valid_types.each do |content_type, filename|
      file = fixture_file_upload(filename, content_type)
      @gallery_image.image.attach(file)
      assert @gallery_image.valid?, "#{content_type} should be valid"
    end
  end

  test "recent scope should order by creation time" do
    @gallery_image.save!
    newer_image = GalleryImage.create!(
      title: "Newer Image",
      user: @user,
      image: @image
    )
    
    assert_equal newer_image, GalleryImage.recent.first
    assert_equal @gallery_image, GalleryImage.recent.second
  end

  test "should generate correct URLs" do
    @gallery_image.save!
    
    assert_match /\/rails\/active_storage\/representations/, @gallery_image.thumbnail_url
    assert_match /\/rails\/active_storage\/representations/, @gallery_image.medium_url
    assert_match /\/rails\/active_storage\/blobs/, @gallery_image.original_url
  end
end
