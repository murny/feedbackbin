# frozen_string_literal: true

require "test_helper"

module Elements
  class DropdownMenuComponentTest < ViewComponent::TestCase
    test "renders basic dropdown with stimulus controller and ARIA" do
      render_inline(DropdownMenuComponent.new) do |dropdown|
        dropdown.with_trigger { "Open" }
        dropdown.with_item_content { "Item 1" }
        dropdown.with_item_content { "Item 2" }
      end

      assert_selector "[data-controller='dropdown']"
      assert_selector "button[data-dropdown-target='trigger'][data-action='click->dropdown#toggle']"
      assert_selector "button[aria-haspopup='true'][aria-expanded='false']"
      assert_selector "[data-dropdown-target='menu'][data-state='closed']"
      assert_selector "[role='menu'][aria-orientation='vertical']"
      assert_selector "button[role='menuitem']", count: 2
      assert_text "Item 1"
      assert_text "Item 2"
    end

    test "renders separator and label components" do
      render_inline(DropdownMenuComponent.new) do |dropdown|
        dropdown.with_trigger { "Open" }
        dropdown.with_item_label { "Section" }
        dropdown.with_item_separator
        dropdown.with_item_content { "Item" }
      end

      assert_selector "[role='separator']"
      assert_text "Section"
    end

    test "renders link items" do
      render_inline(DropdownMenuComponent.new) do |dropdown|
        dropdown.with_trigger { "Open" }
        dropdown.with_item_content(href: "/profile") { "Profile" }
        dropdown.with_item_content(href: "/settings", method: :get) { "Settings" }
      end

      # Both render as links (method: :get is normalized to nil)
      assert_selector "a[href='/profile'][role='menuitem']"
      assert_selector "a[href='/settings'][role='menuitem']"
      assert_selector "a[data-action='click->dropdown#close']", count: 2
      refute_selector "form"
    end

    test "renders form for non-GET methods with ARIA on button" do
      render_inline(DropdownMenuComponent.new) do |dropdown|
        dropdown.with_trigger { "Open" }
        dropdown.with_item_content(href: "/logout", method: :delete) { "Sign out" }
      end

      # Form structure
      assert_selector "form[action='/logout']"
      assert_selector "form input[name='authenticity_token'][type='hidden']", visible: false
      assert_selector "form input[name='_method'][value='delete'][type='hidden']", visible: false

      # ARIA on button, not form
      assert_selector "form button[role='menuitem'][type='submit']"
      refute_selector "form[role='menuitem']"
    end

    test "renders disabled items as non-interactive spans" do
      render_inline(DropdownMenuComponent.new) do |dropdown|
        dropdown.with_trigger { "Open" }
        dropdown.with_item_content(disabled: true, href: "/action") { "Disabled" }
      end

      # Non-interactive span with proper ARIA
      assert_selector "span[role='menuitem'][aria-disabled='true'][data-disabled='true']"

      # No href or action
      refute_selector "a[href='/action']"
      page_html = page.native.to_html

      refute_includes page_html, "click->dropdown#close"
    end

    test "wraps items with id for Turbo updates" do
      render_inline(DropdownMenuComponent.new) do |dropdown|
        dropdown.with_trigger { "Open" }
        dropdown.with_item_content(id: "pin-button", href: "/pin") { "Pin" }
      end

      assert_selector "span#pin-button a[href='/pin']"
    end

    test "preserves custom attributes on wrapper" do
      render_inline(DropdownMenuComponent.new(
        id: "user-menu",
        class: "custom-class",
        data: { controller: "tooltip", testid: "dropdown" },
        aria: { label: "User actions" }
      )) do |dropdown|
        dropdown.with_trigger { "Open" }
        dropdown.with_item_content { "Item" }
      end

      assert_selector "div#user-menu.custom-class"
      assert_selector "[data-testid='dropdown'][aria-label='User actions']"

      # Appends to existing controllers
      page_html = page.native.to_html

      assert_includes page_html, 'data-controller="tooltip dropdown"'
    end

    test "trigger accepts variant and size parameters" do
      render_inline(DropdownMenuComponent.new) do |dropdown|
        dropdown.with_trigger(variant: :ghost, size: :icon, class: "custom") { "Open" }
        dropdown.with_item_content { "Item" }
      end

      page_html = page.native.to_html

      assert_includes page_html, "size-9"  # icon size
      assert_includes page_html, "custom"  # custom class
    end

    test "label accepts custom attributes" do
      render_inline(DropdownMenuComponent.new) do |dropdown|
        dropdown.with_trigger { "Open" }
        dropdown.with_item_label(id: "section", data: { testid: "label" }) { "Section" }
        dropdown.with_item_content { "Item" }
      end

      assert_selector "div#section[data-testid='label']"
    end
  end
end
