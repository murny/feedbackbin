# frozen_string_literal: true

require "test_helper"

module Organizations
  class SwitchesControllerTest < ActionDispatch::IntegrationTest
    setup do
      @organization = organizations(:feedbackbin)
      @user = users(:shane)
      sign_in_as @user
    end

    test "should switch to organization" do
      # Ensure user has membership in the organization
      assert_includes @user.organizations, @organization

      post organization_switch_url(@organization)

      assert_redirected_to root_path
      assert_equal "Switched to #{@organization.name}", flash[:notice]
    end

    test "should not switch to organization user is not member of" do
      other_organization = organizations(:other_organization)

      # Ensure user is not a member
      assert_not @user.organizations.include?(other_organization)

      post organization_switch_url(other_organization)

      assert_redirected_to root_path
      assert_equal "You are not authorized to perform this action.", flash[:alert]
    end
  end
end
