require 'test_helper'

class AchievementTest < ActiveSupport::TestCase
  def setup
    @user = users(:one)
    @achievement = Achievement.new(
      name: "Test Achievement",
      description: "Test description",
      badge_icon: "test_badge.png",
      points: 10,
      category: "commenting"
    )
  end

  test "should be valid" do
    assert @achievement.valid?
  end

  test "should require name" do
    @achievement.name = ""
    assert_not @achievement.valid?
  end

  test "should require unique name" do
    duplicate = @achievement.dup
    @achievement.save
    assert_not duplicate.valid?
  end

  test "should require description" do
    @achievement.description = ""
    assert_not @achievement.valid?
  end

  test "should require badge_icon" do
    @achievement.badge_icon = ""
    assert_not @achievement.valid?
  end

  test "should require points" do
    @achievement.points = nil
    assert_not @achievement.valid?
  end

  test "should require non-negative points" do
    @achievement.points = -1
    assert_not @achievement.valid?
  end

  test "should require valid category" do
    @achievement.category = "invalid"
    assert_not @achievement.valid?
    
    Achievement::CATEGORIES.keys.each do |category|
      @achievement.category = category.to_s
      assert @achievement.valid?
    end
  end

  test "scopes should filter by category" do
    Achievement.delete_all
    commenting = Achievement.create!(
      name: "Commenting Achievement",
      description: "Test",
      badge_icon: "test.png",
      points: 10,
      category: "commenting"
    )
    posting = Achievement.create!(
      name: "Posting Achievement",
      description: "Test",
      badge_icon: "test.png",
      points: 10,
      category: "posting"
    )

    assert_includes Achievement.commenting, commenting
    assert_not_includes Achievement.commenting, posting
    assert_includes Achievement.posting, posting
    assert_not_includes Achievement.posting, commenting
  end

  test "check_achievements_for should award comment achievements" do
    create_comment_achievements
    user = create_user_with_comments(10)
    
    Achievement.check_achievements_for(user)
    
    assert user.achievements.exists?(name: "First Comment")
    assert user.achievements.exists?(name: "Active Commenter")
    assert_not user.achievements.exists?(name: "Comment Expert")
  end

  test "check_achievements_for should award post achievements" do
    create_post_achievements
    user = create_user_with_posts(5)
    
    Achievement.check_achievements_for(user)
    
    assert user.achievements.exists?(name: "First Post")
    assert user.achievements.exists?(name: "Regular Blogger")
    assert_not user.achievements.exists?(name: "Prolific Writer")
  end

  test "check_achievements_for should award engagement achievements" do
    create_engagement_achievements
    user = create_user_with_votes(10)
    
    Achievement.check_achievements_for(user)
    
    assert user.achievements.exists?(name: "First Vote")
    assert user.achievements.exists?(name: "Active Voter")
    assert_not user.achievements.exists?(name: "Super Voter")
  end

  test "check_achievements_for should award reputation achievements" do
    create_reputation_achievements
    user = create_user_with_reputation(100)
    
    Achievement.check_achievements_for(user)
    
    assert user.achievements.exists?(name: "Rising Star")
    assert user.achievements.exists?(name: "Community Voice")
    assert_not user.achievements.exists?(name: "Community Leader")
  end

  test "progress_for should create and return achievement progress" do
    @achievement.save
    progress = @achievement.progress_for(@user)
    
    assert_not_nil progress
    assert_equal @user, progress.user
    assert_equal @achievement, progress.achievement
  end

  test "should not award same achievement twice" do
    create_comment_achievements
    user = create_user_with_comments(1)
    
    assert_difference 'user.achievements.count', 1 do
      Achievement.check_achievements_for(user)
    end
    
    assert_no_difference 'user.achievements.count' do
      Achievement.check_achievements_for(user)
    end
  end

  private

  def create_comment_achievements
    Achievement.create!(
      name: "First Comment",
      description: "Made your first comment",
      badge_icon: "comment1.png",
      points: 5,
      category: "commenting",
      threshold: 1
    )
    Achievement.create!(
      name: "Active Commenter",
      description: "Made 10 comments",
      badge_icon: "comment2.png",
      points: 10,
      category: "commenting",
      threshold: 10
    )
    Achievement.create!(
      name: "Comment Expert",
      description: "Made 50 comments",
      badge_icon: "comment3.png",
      points: 20,
      category: "commenting",
      threshold: 50
    )
  end

  def create_post_achievements
    Achievement.create!(
      name: "First Post",
      description: "Published your first post",
      badge_icon: "post1.png",
      points: 10,
      category: "posting",
      threshold: 1
    )
    Achievement.create!(
      name: "Regular Blogger",
      description: "Published 5 posts",
      badge_icon: "post2.png",
      points: 20,
      category: "posting",
      threshold: 5
    )
    Achievement.create!(
      name: "Prolific Writer",
      description: "Published 20 posts",
      badge_icon: "post3.png",
      points: 30,
      category: "posting",
      threshold: 20
    )
  end

  def create_engagement_achievements
    Achievement.create!(
      name: "First Vote",
      description: "Cast your first vote",
      badge_icon: "vote1.png",
      points: 5,
      category: "engagement",
      threshold: 1
    )
    Achievement.create!(
      name: "Active Voter",
      description: "Cast 10 votes",
      badge_icon: "vote2.png",
      points: 10,
      category: "engagement",
      threshold: 10
    )
    Achievement.create!(
      name: "Super Voter",
      description: "Cast 50 votes",
      badge_icon: "vote3.png",
      points: 20,
      category: "engagement",
      threshold: 50
    )
  end

  def create_reputation_achievements
    Achievement.create!(
      name: "Rising Star",
      description: "Earned 50 reputation",
      badge_icon: "rep1.png",
      points: 10,
      category: "reputation",
      threshold: 50
    )
    Achievement.create!(
      name: "Community Voice",
      description: "Earned 100 reputation",
      badge_icon: "rep2.png",
      points: 20,
      category: "reputation",
      threshold: 100
    )
    Achievement.create!(
      name: "Community Leader",
      description: "Earned 500 reputation",
      badge_icon: "rep3.png",
      points: 50,
      category: "reputation",
      threshold: 500
    )
  end

  def create_user_with_comments(count)
    user = User.create!(
      username: "test_user_#{Time.current.to_i}",
      email: "test#{Time.current.to_i}@example.com",
      password: "password",
      name: "Test User",
      terms_of_service: "1"
    )
    
    count.times do |i|
      Comment.create!(
        content: "Test comment #{i}",
        user: user,
        blog_post: blog_posts(:one)
      )
    end
    
    user
  end

  def create_user_with_posts(count)
    user = User.create!(
      username: "test_user_#{Time.current.to_i}",
      email: "test#{Time.current.to_i}@example.com",
      password: "password",
      name: "Test User",
      terms_of_service: "1"
    )
    
    count.times do |i|
      BlogPost.create!(
        title: "Test post #{i}",
        content: "Test content",
        user: user,
        published: true,
        published_at: Time.current
      )
    end
    
    user
  end

  def create_user_with_votes(count)
    user = User.create!(
      username: "test_user_#{Time.current.to_i}",
      email: "test#{Time.current.to_i}@example.com",
      password: "password",
      name: "Test User",
      terms_of_service: "1"
    )
    
    comment = Comment.create!(
      content: "Test comment",
      user: users(:one),
      blog_post: blog_posts(:one)
    )
    
    count.times do
      Vote.create!(
        user: user,
        comment: comment,
        value: 1
      )
    end
    
    user
  end

  def create_user_with_reputation(points)
    user = User.create!(
      username: "test_user_#{Time.current.to_i}",
      email: "test#{Time.current.to_i}@example.com",
      password: "password",
      name: "Test User",
      terms_of_service: "1"
    )
    
    # Create some achievements to give the user points
    achievement = Achievement.create!(
      name: "Test Achievement",
      description: "Test",
      badge_icon: "test.png",
      points: points,
      category: "reputation"
    )
    
    user.achievements << achievement
    user
  end
end
