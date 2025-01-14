require "application_system_test_case"

class AdminInterfaceTest < ApplicationSystemTestCase
  def setup
    @admin = users(:admin)
  end

  test "admin can access dashboard" do
    sign_in_as(@admin)
    visit admin_dashboard_path
    assert_selector "h1", text: "Admin Dashboard"
  end

  test "admin can navigate using sidebar" do
    sign_in_as(@admin)
    visit admin_dashboard_path
    
    # Test Users submenu functionality
    assert_selector "button", text: "Users"
    
    # Initially, submenu should be hidden
    assert_no_selector "#submenu-users.show"
    
    # Click Users menu
    find("button", text: "Users").click
    
    # Submenu should now be visible
    assert_selector "#submenu-users.show"
    assert_selector "a", text: "List Users"
    assert_selector "a", text: "New User"
    
    # Test navigation to users list
    click_link "List Users"
    assert_current_path admin_users_path
    
    # Test navigation to new user form
    click_link "New User"
    assert_current_path new_admin_user_path
  end

  test "submenu stays open when on users pages" do
    sign_in_as(@admin)
    
    # Visit users index
    visit admin_users_path
    
    # Submenu should be visible because we're in the users section
    assert_selector "#submenu-users.show"
    assert_selector "a", text: "List Users"
    assert_selector "a", text: "New User"
    
    # Visit new user page
    visit new_admin_user_path
    
    # Submenu should still be visible
    assert_selector "#submenu-users.show"
    assert_selector "a", text: "List Users"
    assert_selector "a", text: "New User"
  end

  test "submenu can be toggled multiple times" do
    sign_in_as(@admin)
    visit admin_dashboard_path
    
    # First toggle - open
    find("button", text: "Users").click
    assert_selector "#submenu-users.show"
    
    # Second toggle - close
    find("button", text: "Users").click
    assert_no_selector "#submenu-users.show"
    
    # Third toggle - open again
    find("button", text: "Users").click
    assert_selector "#submenu-users.show"
  end
end
