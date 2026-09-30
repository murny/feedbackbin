# frozen_string_literal: true

require "test_helper"

module Ideas
  class StatusBadgeComponentTest < ViewComponent::TestCase
    test "renders a read-only status badge for non-admins" do
      with_current_user(:jane) do
        render_inline(StatusBadgeComponent.new(idea: ideas(:three)))
      end

      assert_selector "span#idea-status-badge .badge", text: ideas(:three).status_name
      assert_no_selector "#idea-status-open"
    end

    test "renders a status picker with the current status selected for admins" do
      idea = ideas(:three)

      with_current_user(:admin) do
        render_inline(StatusBadgeComponent.new(idea: idea))
      end

      assert_selector "span#idea-status-badge #idea-status-open"
      assert_selector "#idea-status-#{idea.status_id} .fill-selected"
      assert_no_selector "#idea-status-open .fill-selected"
    end
  end
end
