module AuthenticationHelper
  def sign_in_as(user)
    visit new_user_session_path
    fill_in "Username", with: user.username
    fill_in "Password", with: "password123"
    click_button "Sign in"
    assert_current_path root_path
  end
end
