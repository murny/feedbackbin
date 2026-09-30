# frozen_string_literal: true

require "test_helper"

module Ideas
  class CardComponentTest < ViewComponent::TestCase
    test "renders the idea as a navigable list item with title and status" do
      idea = ideas(:three)

      render_inline(CardComponent.new(idea: idea))

      assert_selector "li#idea_#{idea.id}.panel.panel--interactive[data-navigable-list-target='item']"
      assert_selector "h2 a[data-navigable-list-primary-action]", text: idea.title
      assert_selector ".badge", text: idea.status_name
    end

    test "renders the pinned badge when the idea is pinned" do
      idea = ideas(:one)
      idea.pinned = true

      render_inline(CardComponent.new(idea: idea))

      assert_selector ".badge--secondary", text: I18n.t("ideas.idea.pinned")
    end
  end
end
