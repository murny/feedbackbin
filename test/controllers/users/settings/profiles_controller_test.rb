# frozen_string_literal: true

require "test_helper"

class Users::Settings::ProfilesControllerTest < ActionDispatch::IntegrationTest
  setup do
    sign_in(users(:shane))
  end

  test "should get edit" do
    get edit_users_settings_profile_url

    assert_response :success
  end

  test "should be able to update profile" do
    patch users_settings_profile_url, params: {name: "Murny", bio: "I am a developer"}

    assert_redirected_to edit_users_settings_profile_url
    assert_equal "Your profile has been updated.", flash[:notice]
  end
end