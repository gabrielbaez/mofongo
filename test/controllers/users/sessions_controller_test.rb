require "test_helper"

class Users::SessionsControllerTest < ActionDispatch::IntegrationTest
  include Devise::Test::IntegrationHelpers

  def setup
    @user = users(:regular_user)
    @admin = users(:admin)
  end

  test "should get sign in page" do
    get new_user_session_path
    assert_response :success
    assert_select "h2", "Sign in"
  end

  test "should sign in user and redirect to home" do
    post user_session_path, params: { 
      user: { 
        username: @user.username, 
        password: "password123" 
      } 
    }
    assert_redirected_to root_path
    follow_redirect!
    assert_response :success
  end

  test "should sign in admin and redirect to home" do
    post user_session_path, params: { 
      user: { 
        username: @admin.username, 
        password: "password123" 
      } 
    }
    assert_redirected_to root_path
    follow_redirect!
    assert_response :success
  end

  test "should sign out and redirect to home" do
    sign_in @user
    delete destroy_user_session_path
    assert_redirected_to root_path
    follow_redirect!
    assert_response :success
  end

  test "should handle turbo stream sign in" do
    post user_session_path, params: { 
      user: { 
        username: @user.username, 
        password: "password123" 
      } 
    }, headers: { "Accept" => "text/vnd.turbo-stream.html" }
    assert_redirected_to root_path
  end

  test "should handle turbo stream sign out" do
    sign_in @user
    delete destroy_user_session_path, headers: { "Accept" => "text/vnd.turbo-stream.html" }
    assert_redirected_to root_path
  end
end
