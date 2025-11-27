# frozen_string_literal: true

require "test_helper"

module Elements
  class TabsComponentTest < ViewComponent::TestCase
    test "renders tabs with multiple items" do
      items = [
        { label: "Tab 1", value: "tab1", content: "Content 1" },
        { label: "Tab 2", value: "tab2", content: "Content 2" }
      ]

      render_inline(TabsComponent.new(items: items))

      assert_selector "button[role='tab']", count: 2
      assert_selector "div[role='tabpanel']", visible: :all, count: 2
    end

    test "renders tab labels correctly" do
      items = [
        { label: "Account", value: "account", content: "Content" }
      ]

      render_inline(TabsComponent.new(items: items))

      assert_selector "button[role='tab']", text: "Account"
    end

    test "renders tab content" do
      items = [
        { label: "Tab", value: "tab", content: "My Content" }
      ]

      render_inline(TabsComponent.new(items: items))

      assert_text "My Content"
    end

    test "includes Stimulus controller" do
      items = [
        { label: "Tab", value: "tab", content: "Content" }
      ]

      render_inline(TabsComponent.new(items: items))

      assert_selector "[data-controller='tabs']"
    end

    test "includes Stimulus targets" do
      items = [
        { label: "Tab 1", value: "tab1", content: "Content 1" },
        { label: "Tab 2", value: "tab2", content: "Content 2" }
      ]

      render_inline(TabsComponent.new(items: items))

      assert_selector "[data-tabs-target='tab']", count: 2
      assert_selector "[data-tabs-target='panel']", visible: :all, count: 2
    end

    test "sets default index value" do
      items = [
        { label: "Tab", value: "tab", content: "Content" }
      ]

      render_inline(TabsComponent.new(items: items))

      page_html = page.native.to_html

      assert_includes page_html, "data-tabs-index-value=\"0\""
    end

    test "sets custom index value" do
      items = [
        { label: "Tab 1", value: "tab1", content: "Content 1" },
        { label: "Tab 2", value: "tab2", content: "Content 2" }
      ]

      render_inline(TabsComponent.new(items: items, index_value: 1))

      page_html = page.native.to_html

      assert_includes page_html, "data-tabs-index-value=\"1\""
    end

    test "renders icons when provided" do
      items = [
        { label: "User", value: "user", icon: "user", content: "Content" }
      ]

      render_inline(TabsComponent.new(items: items))

      assert_selector "button[role='tab'] svg"
    end

    test "sets disabled attribute on tabs" do
      items = [
        { label: "Tab", value: "tab", disabled: true, content: "Content" }
      ]

      render_inline(TabsComponent.new(items: items))

      assert_selector "button[role='tab'][disabled]"
    end

    test "includes ARIA attributes for tablist" do
      items = [
        { label: "Tab", value: "tab", content: "Content" }
      ]

      render_inline(TabsComponent.new(items: items))

      assert_selector "div[role='tablist']"
      assert_selector "div[role='tablist'][aria-orientation='horizontal']"
    end

    test "includes ARIA attributes for tabs" do
      items = [
        { label: "Tab", value: "my-tab", content: "Content" }
      ]

      render_inline(TabsComponent.new(items: items))

      assert_selector "button[role='tab']"
      assert_selector "button[aria-selected]"
      assert_selector "button[aria-controls='panel-my-tab']"
    end

    test "includes ARIA attributes for panels" do
      items = [
        { label: "Tab", value: "my-tab", content: "Content" }
      ]

      render_inline(TabsComponent.new(items: items))

      assert_selector "div[role='tabpanel']"
      assert_selector "div[aria-labelledby='tab-my-tab']"
    end

    test "first tab is selected by default" do
      items = [
        { label: "Tab 1", value: "tab1", content: "Content 1" },
        { label: "Tab 2", value: "tab2", content: "Content 2" }
      ]

      render_inline(TabsComponent.new(items: items))

      assert_selector "button[aria-selected='true']#tab-tab1"
      assert_selector "button[aria-selected='false']#tab-tab2"
    end

    test "selected tab has correct aria-selected" do
      items = [
        { label: "Tab 1", value: "tab1", content: "Content 1" },
        { label: "Tab 2", value: "tab2", content: "Content 2" }
      ]

      render_inline(TabsComponent.new(items: items, index_value: 1))

      assert_selector "button[aria-selected='false']#tab-tab1"
      assert_selector "button[aria-selected='true']#tab-tab2"
    end

    test "first panel is visible by default" do
      items = [
        { label: "Tab 1", value: "tab1", content: "Content 1" },
        { label: "Tab 2", value: "tab2", content: "Content 2" }
      ]

      render_inline(TabsComponent.new(items: items))

      page_html = page.native.to_html

      # First panel should not have hidden class
      assert_selector "div[role='tabpanel']#panel-tab1:not(.hidden)", visible: :all
      # Second panel should have hidden class
      assert_selector "div[role='tabpanel']#panel-tab2.hidden", visible: :all
    end

    test "selected panel is visible, others hidden" do
      items = [
        { label: "Tab 1", value: "tab1", content: "Content 1" },
        { label: "Tab 2", value: "tab2", content: "Content 2" }
      ]

      render_inline(TabsComponent.new(items: items, index_value: 1))

      assert_selector "div[role='tabpanel'].hidden#panel-tab1", visible: :all
      assert_selector "div[role='tabpanel']:not(.hidden)#panel-tab2", visible: :all
    end

    test "applies container classes" do
      items = [
        { label: "Tab", value: "tab", content: "Content" }
      ]

      render_inline(TabsComponent.new(items: items))

      page_html = page.native.to_html

      # Component uses inline Tailwind classes
      assert_includes page_html, "flex flex-col gap-2"
      assert_includes page_html, "bg-muted"
    end

    test "renders proper semantic structure" do
      items = [
        { label: "Tab", value: "tab", content: "Content" }
      ]

      render_inline(TabsComponent.new(items: items))

      # Tabs are styled via tabs.css, not inline classes
      assert_selector "[role='tablist']"
      assert_selector "[role='tab']"
      assert_selector "[role='tabpanel']"
    end

    test "includes keyboard navigation actions" do
      items = [
        { label: "Tab", value: "tab", content: "Content" }
      ]

      render_inline(TabsComponent.new(items: items))

      page_html = page.native.to_html
      # HTML escaped version of the actions
      assert_includes page_html, "keydown.right-&gt;tabs#nextTab"
      assert_includes page_html, "keydown.left-&gt;tabs#previousTab"
    end

    test "includes click action on tabs" do
      items = [
        { label: "Tab", value: "tab", content: "Content" }
      ]

      render_inline(TabsComponent.new(items: items))

      assert_selector "button[data-action='click->tabs#change']"
    end

    test "panels have tabindex for keyboard focus" do
      items = [
        { label: "Tab", value: "tab", content: "Content" }
      ]

      render_inline(TabsComponent.new(items: items))

      assert_selector "div[role='tabpanel'][tabindex='0']"
    end

    test "renders with custom class" do
      items = [
        { label: "Tab", value: "tab", content: "Content" }
      ]

      render_inline(TabsComponent.new(items: items, class: "custom-class"))

      assert_selector "[data-controller='tabs'].custom-class"
    end

    test "merges custom data attributes" do
      items = [
        { label: "Tab", value: "tab", content: "Content" }
      ]

      render_inline(TabsComponent.new(items: items, data: { test: "value" }))

      assert_selector "[data-test='value']"
    end
  end
end
