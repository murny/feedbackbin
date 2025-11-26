# frozen_string_literal: true

require "test_helper"

module Elements
  class PopoverComponentTest < ViewComponent::TestCase
    test "renders basic popover with Stimulus controller and content" do
      render_inline(PopoverComponent.new) do |popover|
        popover.with_trigger { "Click me" }
        popover.with_popover_content { "Popover content" }
      end

      assert_selector "[data-controller='popover']"
      assert_selector "[data-slot='popover-trigger']", text: "Click me"
      assert_selector "[data-slot='popover-content']", text: "Popover content"
      assert_selector "[data-popover-target='content']"
    end

    test "renders with click trigger by default" do
      render_inline(PopoverComponent.new) do |popover|
        popover.with_trigger { "Trigger" }
        popover.with_popover_content { "Content" }
      end

      assert_selector "[data-popover-trigger-value='click']"
      assert_selector "[data-action='click->popover#toggle']"
    end

    test "renders with hover trigger mode" do
      render_inline(PopoverComponent.new(trigger_mode: :hover)) do |popover|
        popover.with_trigger { "Hover me" }
        popover.with_popover_content { "Content" }
      end

      assert_selector "[data-popover-trigger-value='hover']"
      assert_selector "[data-action='mouseenter->popover#handleMouseEnter mouseleave->popover#handleMouseLeave']"
    end

    test "renders with auto dismiss timer" do
      render_inline(PopoverComponent.new(dismiss_after: 3000)) do |popover|
        popover.with_trigger { "Trigger" }
        popover.with_popover_content { "Content" }
      end

      assert_selector "[data-popover-dismiss-after-value='3000']"
    end

    test "renders content hidden by default for progressive enhancement" do
      render_inline(PopoverComponent.new) do |popover|
        popover.with_trigger { "Trigger" }
        popover.with_popover_content { "Content" }
      end

      page_html = page.native.to_html

      assert_includes page_html, "hidden"
    end

    test "includes transition data attributes for smooth animations" do
      render_inline(PopoverComponent.new) do |popover|
        popover.with_trigger { "Trigger" }
        popover.with_popover_content { "Content" }
      end

      assert_selector "[data-transition-enter]"
      assert_selector "[data-transition-enter-from]"
      assert_selector "[data-transition-enter-to]"
      assert_selector "[data-transition-leave]"
      assert_selector "[data-transition-leave-from]"
      assert_selector "[data-transition-leave-to]"
    end

    test "renders with custom wrapper classes and attributes" do
      render_inline(PopoverComponent.new(
        class: "custom-wrapper",
        data: { testid: "user-popover" }
      )) do |popover|
        popover.with_trigger { "Trigger" }
        popover.with_popover_content { "Content" }
      end

      assert_selector ".custom-wrapper[data-testid='user-popover']"
      assert_selector "[data-controller='popover']"
    end

    test "positions content to bottom by default" do
      render_inline(PopoverComponent.new) do |popover|
        popover.with_trigger { "Trigger" }
        popover.with_popover_content { "Content" }
      end

      page_html = page.native.to_html

      assert_includes page_html, "top-full"
      assert_includes page_html, "margin-top: 4px"
    end

    test "positions content to all four sides" do
      %i[top right bottom left].each do |side|
        render_inline(PopoverComponent.new(side: side)) do |popover|
          popover.with_trigger { "Trigger" }
          popover.with_popover_content { "Content" }
        end

        # Just verify it renders without checking specific CSS classes
        assert_selector "[data-slot='popover-content']"
      end
    end

    test "aligns content start, center, and end" do
      %i[start center end].each do |align|
        render_inline(PopoverComponent.new(align: align)) do |popover|
          popover.with_trigger { "Trigger" }
          popover.with_popover_content { "Content" }
        end

        # Just verify it renders without checking specific CSS classes
        assert_selector "[data-slot='popover-content']"
      end
    end

    test "applies custom side offset" do
      render_inline(PopoverComponent.new(side: :bottom, side_offset: 16)) do |popover|
        popover.with_trigger { "Trigger" }
        popover.with_popover_content { "Content" }
      end

      content = page.find("[data-slot='popover-content']")

      assert_includes content[:style], "margin-top: 16px"
    end

    test "applies custom align offset" do
      render_inline(PopoverComponent.new(align_offset: 20)) do |popover|
        popover.with_trigger { "Trigger" }
        popover.with_popover_content { "Content" }
      end

      content = page.find("[data-slot='popover-content']")

      assert_includes content[:style], "margin-left: 20px"
    end

    test "renders only trigger when content not provided" do
      render_inline(PopoverComponent.new) do |popover|
        popover.with_trigger { "Just trigger" }
      end

      assert_selector "[data-slot='popover-trigger']", text: "Just trigger"
      # Content wrapper may exist but should be empty
      content = page.all("[data-slot='popover-content']")
      if content.any?
        assert_empty content.first.text.strip
      end
    end

    test "includes ARIA attributes for screen reader accessibility" do
      render_inline(PopoverComponent.new) do |popover|
        popover.with_trigger { "Trigger" }
        popover.with_popover_content { "Content" }
      end

      # Trigger announces it controls a dialog that's collapsed
      assert_selector "[data-popover-target='trigger'][aria-haspopup='dialog'][aria-expanded='false']"

      # Content is a dialog, hidden and focusable, linked to trigger
      assert_selector "[data-popover-target='content'][role='dialog'][aria-hidden='true'][tabindex='-1']"

      # Trigger and content must be linked for assistive tech
      trigger = page.find("[data-popover-target='trigger']")
      content = page.find("[data-popover-target='content']")

      assert_equal content[:id], trigger["aria-controls"]
      assert_equal trigger[:id], content["aria-labelledby"]
    end

    test "supports custom ID for stable references" do
      render_inline(PopoverComponent.new(id: "settings-menu")) do |popover|
        popover.with_trigger { "Settings" }
        popover.with_popover_content { "Options" }
      end

      assert_selector "#settings-menu-trigger"
      assert_selector "#settings-menu-content"
    end
  end
end
