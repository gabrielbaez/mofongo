require 'test_helper'

class VotesControllerTest < ActionDispatch::IntegrationTest
  include Devise::Test::IntegrationHelpers

  def setup
    @user = users(:one)
    @comment = comments(:one)
    sign_in @user
  end

  test "should require authentication for create" do
    sign_out @user
    assert_no_difference 'Vote.count' do
      post comment_votes_path(@comment), params: { value: 1 }
    end
    assert_redirected_to new_user_session_path
  end

  test "should create upvote" do
    assert_difference 'Vote.count', 1 do
      post comment_votes_path(@comment), params: { value: 1 }
    end
    assert_equal 1, Vote.last.value
  end

  test "should create downvote" do
    assert_difference 'Vote.count', 1 do
      post comment_votes_path(@comment), params: { value: -1 }
    end
    assert_equal -1, Vote.last.value
  end

  test "should update existing vote" do
    vote = Vote.create!(user: @user, comment: @comment, value: 1)
    assert_no_difference 'Vote.count' do
      post comment_votes_path(@comment), params: { value: -1 }
    end
    assert_equal -1, vote.reload.value
  end

  test "should handle turbo stream format" do
    post comment_votes_path(@comment), 
         params: { value: 1 },
         headers: { "Accept" => "text/vnd.turbo-stream.html" }
    assert_response :success
    assert_equal "text/vnd.turbo-stream.html", response.media_type
  end

  test "should handle html format" do
    post comment_votes_path(@comment), params: { value: 1 }
    assert_redirected_to root_path
  end

  test "should require authentication for destroy" do
    vote = Vote.create!(user: @user, comment: @comment, value: 1)
    sign_out @user
    assert_no_difference 'Vote.count' do
      delete comment_vote_path(@comment, vote)
    end
    assert_redirected_to new_user_session_path
  end

  test "should destroy vote" do
    vote = Vote.create!(user: @user, comment: @comment, value: 1)
    assert_difference 'Vote.count', -1 do
      delete comment_vote_path(@comment, vote)
    end
  end

  test "should handle turbo stream format for destroy" do
    vote = Vote.create!(user: @user, comment: @comment, value: 1)
    delete comment_vote_path(@comment, vote),
           headers: { "Accept" => "text/vnd.turbo-stream.html" }
    assert_response :success
    assert_equal "text/vnd.turbo-stream.html", response.media_type
  end

  test "should handle html format for destroy" do
    vote = Vote.create!(user: @user, comment: @comment, value: 1)
    delete comment_vote_path(@comment, vote)
    assert_redirected_to root_path
  end
end
