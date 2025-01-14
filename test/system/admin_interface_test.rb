require "application_system_test_case"

class AdminInterfaceTest < ApplicationSystemTestCase
  def setup
    @admin = users(:admin)
  end

  test "admin can access dashboard" do
    sign_in_as(@admin)
    visit admin_dashboard_path
    
    # Test dashboard header
    assert_selector "h1.text-gray-800", text: "Dashboard"
    
    # Test stats cards
    assert_selector ".text-xs.font-weight-bold", text: "TOTAL USERS"
    assert_selector ".text-xs.font-weight-bold", text: "ACTIVE USERS (24H)"
    assert_selector ".text-xs.font-weight-bold", text: "NEW USERS (24H)"
    assert_selector ".text-xs.font-weight-bold", text: "ENVIRONMENT"
    
    # Test icons
    assert_selector "i.fas.fa-users"
    assert_selector "i.fas.fa-user-check"
    assert_selector "i.fas.fa-user-plus"
    assert_selector "i.fas.fa-server"
  end

  test "admin can navigate using sidebar" do
    sign_in_as(@admin)
    visit admin_dashboard_path
    
    # Test Users link presence with icon
    within(".nav.nav-pills") do
      assert_selector "a.nav-link", text: /Users/
      assert_selector "i.fas.fa-users"
    end
    
    # Test direct navigation to users list
    click_link "Users"
    assert_current_path admin_users_path
  end

  test "admin sidebar shows user information" do
    sign_in_as(@admin)
    visit admin_dashboard_path
    
    within(".dropdown") do
      assert_selector ".rounded-circle", text: @admin.name.first
      assert_selector "strong", text: @admin.name
    end
  end

  test "admin can use user dropdown menu" do
    sign_in_as(@admin)
    visit admin_dashboard_path
    
    # Open dropdown menu
    find("#dropdownUser1").click
    
    within(".dropdown-menu") do
      assert_selector "a.dropdown-item", text: "Profile"
      assert_selector "a.dropdown-item", text: "Sign out"
    end
    
    # Test profile navigation
    click_link "Profile"
    assert_current_path edit_user_registration_path
  end
end
