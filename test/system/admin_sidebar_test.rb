require "application_system_test_case"

class AdminSidebarTest < ApplicationSystemTestCase
  include Devise::Test::IntegrationHelpers

  SCREEN_SIZES = [
    [1400, 800],  # Desktop
    [768, 1024],  # Tablet
    [375, 812]    # Mobile
  ].freeze

  setup do
    @admin = users(:admin)
    sign_in @admin
    visit admin_dashboard_path
  end

  test "sidebar layout and structure" do
    assert_selector ".d-flex.flex-column.flex-shrink-0.bg-dark.h-100"
    assert_selector ".d-flex.align-items-center.mb-3", text: "Mofongo Admin"
    assert_selector "hr", count: 2
  end

  test "navigation menu structure and active states" do
    within(".nav.nav-pills.flex-column") do
      verify_dashboard_active_state
      navigate_to_users_and_verify_state
    end
  end

  test "user profile dropdown functionality" do
    verify_dropdown_structure
    verify_dropdown_interaction
    verify_profile_navigation
  end

  test "responsive layout behavior" do
    SCREEN_SIZES.each do |width, height|
      page.driver.browser.manage.window.resize_to(width, height)
      verify_sidebar_styling
    end
  end

  test "main content interaction with sidebar" do
    verify_main_content_layout
    add_scrollable_content
    verify_sidebar_position
  end

  private

  def verify_dashboard_active_state
    dashboard_link = find_link("Dashboard")
    assert dashboard_link[:class].include?("nav-link"),
           "Expected link to have nav-link class"
    assert_includes dashboard_link[:class], "active",
                    "Expected Dashboard to be active"
  end

  def navigate_to_users_and_verify_state
    click_link "Users"
    assert_current_path admin_users_path
    assert_selector "a.nav-link.active", text: "Users", wait: 5
    assert_no_selector "a.nav-link.active", text: "Dashboard", wait: 5
  end

  def verify_dropdown_structure
    @dropdown_toggle = find("#dropdownUser1")
    assert_selector ".rounded-circle", text: @admin.name.first
    assert_text @admin.name
  end

  def verify_dropdown_interaction
    @dropdown_toggle.click
    within(".dropdown-menu") do
      assert_link "Profile"
      assert_link "Sign out"
    end
  end

  def verify_profile_navigation
    click_link "Profile"
    assert_current_path edit_user_registration_path
  end

  def verify_sidebar_styling
    assert_selector ".d-flex.flex-column.flex-shrink-0.bg-dark.h-100"
    assert_selector ".nav.nav-pills.flex-column"
  end

  def verify_main_content_layout
    assert_selector "main.flex-grow-1.overflow-auto"
  end

  def add_scrollable_content
    execute_script(
      "document.querySelector(\"main\").innerHTML += " \
      "<div style=\"height: 2000px;\"></div>"
    )
    execute_script("document.querySelector(\"main\").scrollTop = 500")
  end

  def verify_sidebar_position
    sidebar = find(".d-flex.flex-column.flex-shrink-0.bg-dark")
    assert_includes sidebar[:class], "h-100"
  end
end
