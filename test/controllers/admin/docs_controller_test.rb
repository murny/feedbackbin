# frozen_string_literal: true

require "test_helper"

class Admin::DocsControllerTest < ActionDispatch::IntegrationTest
  test "should get introduction doc as admin" do
    sign_in_as users(:shane)

    get admin_docs_introduction_path

    assert_response :success
  end

  test "should get installation doc as admin" do
    sign_in_as users(:shane)

    get admin_docs_installation_path

    assert_response :success
  end

  test "should get configuration doc as admin" do
    sign_in_as users(:shane)

    get admin_docs_configuration_path

    assert_response :success
  end

  test "should get deploying doc as admin" do
    sign_in_as users(:shane)

    get admin_docs_deploying_path

    assert_response :success
  end
end
