# frozen_string_literal: true

require "test_helper"

class StaticControllerTest < ActionDispatch::IntegrationTest
  test "should get about" do
    get about_url

    assert_response :success
  end

  test "should get privacy" do
    get privacy_url

    assert_response :success
  end

  test "should get terms" do
    get terms_url

    assert_response :success
  end
end
