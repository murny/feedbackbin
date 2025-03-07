# frozen_string_literal: true

require "test_helper"

class Admin::DocsControllerTest < ActionDispatch::IntegrationTest
  test "should not get docs when not logged in" do
    get introduction_admin_docs_path

    assert_response :not_found
  end

  test "should not get show as non admin user" do
    sign_in_as users(:one)

    get introduction_admin_docs_path

    assert_response :not_found
  end

  test "should get introduction doc as admin" do
    sign_in_as users(:shane)

    get introduction_admin_docs_path

    assert_response :success
  end

  test "should get installation doc as admin" do
    sign_in_as users(:shane)

    get installation_admin_docs_path

    assert_response :success
  end

  test "should get configuration doc as admin" do
    sign_in_as users(:shane)

    get configuration_admin_docs_path

    assert_response :success
  end

  test "should get deploying doc as admin" do
    sign_in_as users(:shane)

    get deploying_admin_docs_path

    assert_response :success
  end

  test "should get breadcrumb doc as admin" do
    sign_in_as users(:shane)

    get breadcrumb_admin_docs_path

    assert_response :success
  end

  test "should get button doc as admin" do
    sign_in_as users(:shane)

    get button_admin_docs_path

    assert_response :success
  end

  test "should get toast doc as admin" do
    sign_in_as users(:shane)

    get toast_admin_docs_path

    assert_response :success
  end
end
