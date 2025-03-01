# frozen_string_literal: true

require "test_helper"

class Admin::Docs::ComponentsControllerTest < ActionDispatch::IntegrationTest
  test "should not get show when not logged in" do
    get admin_docs_component_path(id: "buttons")

    assert_response :not_found
  end

  test "should not get show as non admin user" do
    sign_in_as users(:one)

    get admin_docs_component_path(id: "buttons")

    assert_response :not_found
  end

  test "should get show as admin for buttons component" do
    sign_in_as users(:shane)

    get admin_docs_component_path(id: "buttons")

    assert_response :success
  end

  test "should get show as admin for alert component" do
    sign_in_as users(:shane)

    get admin_docs_component_path(id: "alert")

    assert_response :success
  end

  test "should raise error for non-existent component" do
    sign_in_as users(:shane)

    assert_raises(ActionView::MissingTemplate) do
      get admin_docs_component_path(id: "non_existent_component")
    end
  end
end
