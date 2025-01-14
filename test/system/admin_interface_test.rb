require "application_system_test_case"

class AdminInterfaceTest < ApplicationSystemTestCase
  def setup
    @admin = users(:admin)
  end

  test "admin can access dashboard" do
    sign_in_as(@admin)
    visit admin_dashboard_path
    assert_selector "h1", text: "Dashboard"
    assert_selector "i.fas.fa-gauge" # Test for dashboard icon
  end

  test "admin can navigate using sidebar" do
    sign_in_as(@admin)
    visit admin_dashboard_path
    
    # Test Users menu presence
    assert_selector ".sidebar-menu a", text: "Users"
    assert_selector "i.fas.fa-users" # Test for users icon
    
    # Initially, submenu should be hidden
    assert_no_selector ".sidebar-submenu ul"
    
    # Click Users menu
    find(".sidebar-menu a", text: "Users").click
    
    # Submenu should now be visible with proper icons
    assert_selector ".sidebar-submenu ul"
    within(".sidebar-submenu") do
      assert_selector "i.fas.fa-list" # Test for list icon
      assert_selector "i.fas.fa-user-plus" # Test for new user icon
      assert_selector "a", text: "List Users"
      assert_selector "a", text: "New User"
    end
    
    # Test navigation to users list
    click_link "List Users"
    assert_current_path admin_users_path
    
    # Test navigation to new user form
    visit admin_dashboard_path # Go back to test navigation again
    find(".sidebar-menu a", text: "Users").click
    click_link "New User"
    assert_current_path new_admin_user_path
  end

  test "admin sidebar shows correct user role" do
    sign_in_as(@admin)
    visit admin_dashboard_path
    
    within(".user-info") do
      assert_selector ".user-role", text: "Admin"
      assert_selector ".user-status", text: "Online"
    end
  end

  test "admin can toggle sidebar" do
    sign_in_as(@admin)
    visit admin_dashboard_path
    
    # Test sidebar toggle functionality
    assert_selector "#show-sidebar"
    assert_selector "#close-sidebar"
    
    find("#close-sidebar").click
    assert_no_selector ".page-wrapper.toggled"
    
    find("#show-sidebar").click
    assert_selector ".page-wrapper.toggled"
  end
end
