require 'test_helper'

class UserTest < ActiveSupport::TestCase
  def setup
    @user = User.new(
      username: 'testuser',
      name: 'Test User',
      email: 'test@example.com',
      password: 'password123',
      password_confirmation: 'password123',
      terms_of_service: '1'
    )
  end

  test 'should be valid' do
    assert @user.valid?
  end

  # Validation tests
  test 'name should be present' do
    @user.name = ''
    assert_not @user.valid?
  end

  test 'email should be present' do
    @user.email = ''
    assert_not @user.valid?
  end

  test 'username should be present' do
    @user.username = ''
    assert_not @user.valid?
  end

  test 'username should be unique' do
    duplicate_user = @user.dup
    duplicate_user.email = 'other@example.com'
    @user.save
    assert_not duplicate_user.valid?
  end

  test 'username format should be valid' do
    valid_usernames = %w[user123 user_name user-name]
    valid_usernames.each do |valid_username|
      @user.username = valid_username
      assert @user.valid?, "#{valid_username.inspect} should be valid"
    end
  end

  test 'username format should be invalid' do
    invalid_usernames = ['user name', 'user@name', 'user.name']
    invalid_usernames.each do |invalid_username|
      @user.username = invalid_username
      assert_not @user.valid?, "#{invalid_username.inspect} should be invalid"
    end
  end

  test 'username length should be within bounds' do
    @user.username = 'a' * 2
    assert_not @user.valid?
    @user.username = 'a' * 31
    assert_not @user.valid?
    @user.username = 'a' * 15
    assert @user.valid?
  end

  test 'email should be unique' do
    duplicate_user = @user.dup
    duplicate_user.username = 'other_user'
    @user.save
    assert_not duplicate_user.valid?
  end

  # Role tests
  test 'default role should be user' do
    @user.save
    assert @user.user?
  end

  test 'should change role to administrator' do
    @user.save
    @user.administrator!
    assert @user.administrator?
  end

  test 'should change role to moderator' do
    @user.save
    @user.moderator!
    assert @user.moderator?
  end

  # Association tests
  test 'should destroy dependent blog posts' do
    @user.save
    @user.blog_posts.create!(title: 'Test Post', content: 'Test content', published: true)
    assert_difference 'BlogPost.count', -1 do
      @user.destroy
    end
  end

  # Instance method tests
  test 'display_name should return username' do
    assert_equal @user.username, @user.display_name
  end

  test 'following methods should work correctly' do
    @user.save
    other_user = User.create!(
      username: 'other_user',
      name: 'Other User',
      email: 'other@example.com',
      password: 'password123',
      password_confirmation: 'password123',
      terms_of_service: '1'
    )

    assert_not @user.following?(other_user)
    @user.follow(other_user)
    assert @user.following?(other_user)
    @user.unfollow(other_user)
    assert_not @user.following?(other_user)
  end

  test 'should not be able to follow self' do
    @user.save
    assert_no_difference '@user.following.count' do
      @user.follow(@user)
    end
  end

  # Callback tests
  test 'email should be downcased before save' do
    mixed_case_email = 'TeSt@ExAmPlE.CoM'
    @user.email = mixed_case_email
    @user.save
    assert_equal mixed_case_email.downcase, @user.reload.email
  end

  test 'should set username from email if not provided' do
    user = User.new(
      name: 'Test User',
      email: 'test.user@example.com',
      password: 'password123',
      password_confirmation: 'password123',
      terms_of_service: '1'
    )
    user.save
    assert_equal 'test.user', user.username
  end

  test 'should append number to username if taken' do
    @user.save
    second_user = User.new(
      name: 'Test User 2',
      email: 'test@example2.com',
      password: 'password123',
      password_confirmation: 'password123',
      terms_of_service: '1',
      username: 'testuser'
    )
    second_user.save
    assert_equal 'testuser1', second_user.username
  end

  # Comment stats tests
  test 'comment_stats should return correct values' do
    @user.save
    assert_equal({
      total_comments: 0,
      total_score: 0,
      avg_score: 0
    }, @user.comment_stats)
  end
end
