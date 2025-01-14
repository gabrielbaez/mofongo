require "application_system_test_case"

class AdminSidebarTest < ApplicationSystemTestCase
  include Devise::Test::IntegrationHelpers

  setup do
    @admin = users(:admin)
    sign_in @admin
    visit admin_dashboard_path
  end

  test "sidebar layout and structure" do
    # Verify sidebar container
    assert_selector ".d-flex.flex-column.flex-shrink-0.bg-dark.h-100"
    
    # Verify sidebar header
    assert_selector ".d-flex.align-items-center.mb-3", text: "Mofongo Admin"
    assert_selector "hr", count: 2  # One after header, one before user dropdown
  end

  test "navigation menu structure and active states" do
    within(".nav.nav-pills.flex-column") do
      # Verify Dashboard link and active state
      dashboard_link = find_link("Dashboard")
      assert dashboard_link[:class].include?("nav-link"), "Expected link to have nav-link class"
      assert_includes dashboard_link[:class], "active", "Expected Dashboard to be active"
      
      # Click Users link and verify state change
      click_link "Users"
      assert_current_path admin_users_path
      
      # Verify Users link becomes active and Dashboard becomes inactive
      assert_selector "a.nav-link.active", text: "Users", wait: 5
      assert_no_selector "a.nav-link.active", text: "Dashboard", wait: 5
    end
  end

  test "user profile dropdown functionality" do
    # Verify dropdown structure
    dropdown_toggle = find("#dropdownUser1")
    assert_selector ".rounded-circle", text: @admin.name.first
    assert_text @admin.name
    
    # Test dropdown interaction
    dropdown_toggle.click
    within(".dropdown-menu") do
      assert_link "Profile"
      assert_link "Sign out"
    end
    
    # Test profile navigation
    click_link "Profile"
    assert_current_path edit_user_registration_path
  end

  test "responsive layout behavior" do
    # Test at different screen sizes
    [
      [1400, 800],  # Desktop
      [768, 1024],  # Tablet
      [375, 812]    # Mobile
    ].each do |width, height|
      page.driver.browser.manage.window.resize_to(width, height)
      
      # Verify sidebar remains properly styled
      assert_selector ".d-flex.flex-column.flex-shrink-0.bg-dark.h-100"
      assert_selector ".nav.nav-pills.flex-column"
    end
  end

  test "main content interaction with sidebar" do
    # Verify main content layout
    assert_selector "main.flex-grow-1.overflow-auto"
    
    # Add content to test scrolling
    execute_script("document.querySelector('main').innerHTML += '<div style=\"height: 2000px;\"></div>'")
    
    # Scroll main content
    execute_script("document.querySelector('main').scrollTop = 500")
    
    # Verify sidebar remains in place
    sidebar = find(".d-flex.flex-column.flex-shrink-0.bg-dark")
    assert_includes sidebar[:class], "h-100"
  end
end
