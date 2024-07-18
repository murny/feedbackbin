# frozen_string_literal: true

require "test_helper"

class FeedbacksTest < ActionDispatch::IntegrationTest
  test "Feedback homepage" do
    get root_path

    assert_response :success
    assert_select "h1", I18n.t("feedbacks.index.title")
  end
end
