# frozen_string_literal: true

require "test_helper"

module Ideas
  class StatusesControllerTest < ActionDispatch::IntegrationTest
    setup do
      @idea = ideas(:one)
      @admin_user = users(:shane)
      @planned_status = statuses(:planned)
      @open_status = statuses(:open)
    end

    test "should update idea status when user is admin" do
      sign_in_as(@admin_user)

      assert_equal @open_status, @idea.status

      patch idea_status_path(@idea), params: { status_id: @planned_status.id }

      assert_response :redirect
      assert_redirected_to @idea
      assert_equal @planned_status, @idea.reload.status
    end

    test "should deny unauthenticated user from updating status" do
      patch idea_status_path(@idea), params: { status_id: @planned_status.id }

      assert_response :redirect
      assert_equal @open_status, @idea.reload.status
    end

    test "should deny non-admin user from updating status" do
      non_admin = users(:one)
      sign_in_as(non_admin)

      patch idea_status_path(@idea), params: { status_id: @planned_status.id }

      assert_response :redirect
      assert_equal @open_status, @idea.reload.status
    end
  end
end
