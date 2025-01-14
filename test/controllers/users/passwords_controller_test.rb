require "test_helper"

class Users::PasswordsControllerTest < ActionDispatch::IntegrationTest
  include Devise::Test::IntegrationHelpers

  def setup
    @user = users(:regular_user)
  end

  test "should get forgot password page" do
    get new_user_password_path
    assert_response :success
    assert_select "h2", "Forgot your password?"
  end

  test "should send reset password instructions" do
    assert_emails 1 do
      post user_password_path, params: {
        user: {
          username: @user.username
        }
      }
    end
    assert_redirected_to new_user_session_path
  end

  test "should not send reset instructions for non-existent username" do
    assert_no_emails do
      post user_password_path, params: {
        user: {
          username: "nonexistent"
        }
      }
    end
    assert_response :unprocessable_entity
  end

  test "should get change password page with valid token" do
    token = @user.send_reset_password_instructions
    get edit_user_password_path(reset_password_token: token)
    assert_response :success
    assert_select "h2", "Change your password"
  end

  test "should not get change password page with invalid token" do
    get edit_user_password_path(reset_password_token: "invalid_token")
    assert_redirected_to new_user_session_path
  end

  test "should change password with valid token" do
    token = @user.send_reset_password_instructions
    put user_password_path, params: {
      user: {
        reset_password_token: token,
        password: "newpassword123",
        password_confirmation: "newpassword123"
      }
    }
    assert_redirected_to root_path
    
    # Verify can sign in with new password
    post user_session_path, params: {
      user: {
        username: @user.username,
        password: "newpassword123"
      }
    }
    assert_redirected_to root_path
  end

  test "should not change password with invalid token" do
    put user_password_path, params: {
      user: {
        reset_password_token: "invalid_token",
        password: "newpassword123",
        password_confirmation: "newpassword123"
      }
    }
    assert_response :unprocessable_entity
  end

  test "should not change password with mismatched confirmation" do
    token = @user.send_reset_password_instructions
    put user_password_path, params: {
      user: {
        reset_password_token: token,
        password: "newpassword123",
        password_confirmation: "differentpassword123"
      }
    }
    assert_response :unprocessable_entity
  end
end
