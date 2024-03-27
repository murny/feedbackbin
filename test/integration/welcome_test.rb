# frozen_string_literal: true

require "test_helper"

class WelcomeTest < ActionDispatch::IntegrationTest
  test "homepage" do
    get root_path

    assert_response :success
    assert_select "h1", I18n.t("welcome.show.title")
  end
end
