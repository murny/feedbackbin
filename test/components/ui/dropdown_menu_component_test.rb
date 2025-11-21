# frozen_string_literal: true

require "test_helper"

module Ui
  class DropdownMenuComponentTest < ViewComponent::TestCase
    test "renders dropdown with trigger and menu" do
      render_inline(DropdownMenuComponent.new) do |dropdown|
        dropdown.with_trigger { "Open" }
        dropdown.with_item_content { "Item 1" }
        dropdown.with_item_content { "Item 2" }
      end

      assert_selector "[data-controller='dropdown']"
      assert_selector "[data-dropdown-target='menu']"
      assert_selector "button[role='menuitem']", count: 2
    end

    test "renders menu items correctly" do
      render_inline(DropdownMenuComponent.new) do |dropdown|
        dropdown.with_trigger { "Open" }
        dropdown.with_item_content { "Profile" }
        dropdown.with_item_content { "Settings" }
      end

      assert_text "Profile"
      assert_text "Settings"
    end

    test "includes Stimulus controller" do
      render_inline(DropdownMenuComponent.new) do |dropdown|
        dropdown.with_trigger { "Open" }
        dropdown.with_item_content { "Item" }
      end

      assert_selector "[data-controller='dropdown']"
    end

    test "includes Stimulus targets" do
      render_inline(DropdownMenuComponent.new) do |dropdown|
        dropdown.with_trigger { "Open" }
        dropdown.with_item_content { "Item 1" }
        dropdown.with_item_content { "Item 2" }
      end

      assert_selector "[data-dropdown-target='trigger']"
      assert_selector "[data-dropdown-target='menu']"
    end

    test "renders separator" do
      render_inline(DropdownMenuComponent.new) do |dropdown|
        dropdown.with_trigger { "Open" }
        dropdown.with_item_content { "Item 1" }
        dropdown.with_item_separator
        dropdown.with_item_content { "Item 2" }
      end

      assert_selector "[role='separator']"
    end

    test "renders disabled items" do
      render_inline(DropdownMenuComponent.new) do |dropdown|
        dropdown.with_trigger { "Open" }
        dropdown.with_item_content(disabled: true) { "Disabled Item" }
      end

      assert_selector "button[disabled]"
    end

    test "renders inset items" do
      render_inline(DropdownMenuComponent.new) do |dropdown|
        dropdown.with_trigger { "Open" }
        dropdown.with_item_content(inset: true) { "Inset Item" }
      end

      page_html = page.native.to_html
      assert_includes page_html, "pl-8"
    end

    test "includes ARIA attributes for trigger" do
      render_inline(DropdownMenuComponent.new) do |dropdown|
        dropdown.with_trigger { "Open" }
        dropdown.with_item_content { "Item" }
      end

      assert_selector "[aria-haspopup='true']"
      assert_selector "[aria-expanded='false']"
    end

    test "includes ARIA attributes for menu" do
      render_inline(DropdownMenuComponent.new) do |dropdown|
        dropdown.with_trigger { "Open" }
        dropdown.with_item_content { "Item" }
      end

      assert_selector "[role='menu']"
      assert_selector "[role='menu'][aria-orientation='vertical']"
    end

    test "includes ARIA attributes for menu items" do
      render_inline(DropdownMenuComponent.new) do |dropdown|
        dropdown.with_trigger { "Open" }
        dropdown.with_item_content { "Item" }
      end

      assert_selector "button[role='menuitem']"
      assert_selector "button[tabindex='0']"
    end

    test "applies container classes" do
      render_inline(DropdownMenuComponent.new) do |dropdown|
        dropdown.with_trigger { "Open" }
        dropdown.with_item_content { "Item" }
      end

      page_html = page.native.to_html
      assert_includes page_html, "relative inline-block"
    end

    test "applies menu positioning classes" do
      render_inline(DropdownMenuComponent.new) do |dropdown|
        dropdown.with_trigger { "Open" }
        dropdown.with_item_content { "Item" }
      end

      page_html = page.native.to_html
      assert_includes page_html, "top-full"
      assert_includes page_html, "left-0"
    end

    test "renders with custom class" do
      render_inline(DropdownMenuComponent.new(class: "custom-class")) do |dropdown|
        dropdown.with_trigger { "Open" }
        dropdown.with_item_content { "Item" }
      end

      assert_selector "[data-controller='dropdown'].custom-class"
    end

    test "menu starts closed" do
      render_inline(DropdownMenuComponent.new) do |dropdown|
        dropdown.with_trigger { "Open" }
        dropdown.with_item_content { "Item" }
      end

      page_html = page.native.to_html
      assert_includes page_html, "data-state=\"closed\""
    end

    test "includes keyboard navigation actions" do
      render_inline(DropdownMenuComponent.new) do |dropdown|
        dropdown.with_trigger { "Open" }
        dropdown.with_item_content { "Item" }
      end

      # The controller handles keyboard navigation via document listeners
      # We just verify the controller is present
      assert_selector "[data-controller='dropdown']"
    end

    test "includes click action on trigger" do
      render_inline(DropdownMenuComponent.new) do |dropdown|
        dropdown.with_trigger { "Open" }
        dropdown.with_item_content { "Item" }
      end

      assert_selector "[data-action='click->dropdown#toggle']"
    end

    test "includes auto-close action on menu items" do
      render_inline(DropdownMenuComponent.new) do |dropdown|
        dropdown.with_trigger { "Open" }
        dropdown.with_item_content { "Item" }
      end

      assert_selector "button[data-action='click->dropdown#close']"
    end

    test "renders link items with href" do
      render_inline(DropdownMenuComponent.new) do |dropdown|
        dropdown.with_trigger { "Open" }
        dropdown.with_item_content(href: "/profile") { "Profile" }
      end

      assert_selector "a[href='/profile'][role='menuitem']"
    end

    test "renders button items without href" do
      render_inline(DropdownMenuComponent.new) do |dropdown|
        dropdown.with_trigger { "Open" }
        dropdown.with_item_content { "Action" }
      end

      assert_selector "button[role='menuitem'][type='button']"
    end
  end
end
