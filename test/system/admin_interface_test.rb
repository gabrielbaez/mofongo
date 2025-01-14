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
    assert_selector ".sidebar-menu a", text: "Users"
    assert_selector "i.fas.fa-users"
    
    # Test direct navigation to users list
    click_link "Users"
    assert_current_path admin_users_path
  end

  test "admin sidebar shows correct user role" do
    sign_in_as(@admin)
    visit admin_dashboard_path
    
    within(".user-info") do
      assert_selector ".user-role", text: "Administrator"
      assert_selector ".user-status", text: "Online"
    end
  end

  test "admin can toggle sidebar" do
    skip "Sidebar toggle functionality is currently being fixed"
    
    sign_in_as(@admin)
    visit admin_dashboard_path
    
    # Wait for Turbo to finish loading and JavaScript to initialize
    assert_selector ".page-wrapper"
    assert_selector "#show-sidebar"
    sleep 1.0
    
    # Debug information
    puts "Initial page-wrapper classes: #{find('.page-wrapper')['class']}"
    
    # Test initial state (sidebar is hidden by default)
    assert_no_selector ".page-wrapper.toggled"
    
    # Test opening sidebar
    find("#show-sidebar").click
    sleep 1.0
    
    # Debug information
    puts "After clicking show-sidebar: #{find('.page-wrapper')['class']}"
    
    assert_selector ".page-wrapper.toggled"
    
    # Test closing sidebar
    find("#close-sidebar").click
    sleep 1.0
    
    # Debug information
    puts "After clicking close-sidebar: #{find('.page-wrapper')['class']}"
    
    assert_no_selector ".page-wrapper.toggled"
  end

  test "admin dashboard shows user distribution" do
    sign_in_as(@admin)
    visit admin_dashboard_path
    
    # Test user distribution section
    within(".chart-area") do
      assert_selector "i.fas.fa-user-shield"
      assert_selector "i.fas.fa-user-cog"
      assert_selector "i.fas.fa-user"
      assert_selector "h4", text: "Administrators"
      assert_selector "h4", text: "Moderators"
      assert_selector "h4", text: "Regular Users"
    end
  end

  test "admin dashboard shows system information" do
    sign_in_as(@admin)
    visit admin_dashboard_path
    
    # Test system information section
    within(".card", text: /System Information/) do
      assert_selector "i.fas.fa-gem"
      assert_selector "i.fas.fa-train"
      assert_selector "i.fas.fa-clock"
      assert_text "Ruby Version:"
      assert_text "Rails Version:"
      assert_text "Server Time:"
    end
  end
end
