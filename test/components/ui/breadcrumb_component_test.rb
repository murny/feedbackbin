# frozen_string_literal: true

require "test_helper"

module Ui
  class BreadcrumbComponentTest < ViewComponent::TestCase
    test "renders breadcrumb with multiple items" do
      items = [
        { text: "Home", path: "/" },
        { text: "Products", path: "/products" },
        { text: "Current" }
      ]

      render_inline(BreadcrumbComponent.new(items: items))

      assert_selector "nav[aria-label='breadcrumb']"
      assert_selector "ol"
      assert_selector "li", count: 5 # 3 items + 2 separators
    end

    test "renders links for items with path" do
      items = [
        { text: "Home", path: "/" },
        { text: "Products", path: "/products" }
      ]

      render_inline(BreadcrumbComponent.new(items: items))

      assert_selector "a[href='/']", text: "Home"
      assert_selector "a[href='/products']", text: "Products"
    end

    test "renders last item as current page indicator" do
      items = [
        { text: "Home", path: "/" },
        { text: "Current" }
      ]

      render_inline(BreadcrumbComponent.new(items: items))

      assert_selector "span[aria-current='page']", text: "Current"
      assert_no_selector "a", text: "Current"
    end

    test "renders n-1 separators for n items" do
      render_inline(BreadcrumbComponent.new(items: [
        { text: "Home", path: "/" },
        { text: "Current" }
      ]))

      assert_selector "li[data-slot='breadcrumb-separator']", count: 1
    end

    test "supports custom text separator" do
      items = [
        { text: "Home", path: "/" },
        { text: "Current" }
      ]

      render_inline(BreadcrumbComponent.new(items: items, separator: "->"))

      assert_text "->"
    end

    test "collapses long breadcrumb to first...last when enabled" do
      items = [
        { text: "Item 1", path: "/1" },
        { text: "Item 2", path: "/2" },
        { text: "Item 3", path: "/3" },
        { text: "Item 4", path: "/4" },
        { text: "Item 5" }
      ]

      render_inline(BreadcrumbComponent.new(items: items, collapse: true))

      # Should show: first, ellipsis, last
      assert_selector "a", text: "Item 1"
      assert_selector ".sr-only", text: "More" # Ellipsis with sr-only text
      assert_selector "span[aria-current='page']", text: "Item 5"
      assert_no_selector "a", text: "Item 2"
      assert_no_selector "a", text: "Item 3"
      assert_no_selector "a", text: "Item 4"
    end

    test "does not collapse breadcrumb with 3 or fewer items" do
      items = [
        { text: "Item 1", path: "/1" },
        { text: "Item 2", path: "/2" },
        { text: "Item 3" }
      ]

      render_inline(BreadcrumbComponent.new(items: items, collapse: true))

      # All items should be visible
      assert_selector "a", text: "Item 1"
      assert_selector "a", text: "Item 2"
      assert_selector "span[aria-current='page']", text: "Item 3"
    end

    test "renders single item without separators" do
      items = [ { text: "Home" } ]

      render_inline(BreadcrumbComponent.new(items: items))

      assert_selector "li", count: 1 # Just the item, no separator
      assert_selector "span[aria-current='page']", text: "Home"
    end

    test "makes ellipsis accessible to screen readers" do
      items = [
        { text: "Item 1", path: "/1" },
        { text: "Item 2", path: "/2" },
        { text: "Item 3", path: "/3" },
        { text: "Item 4", path: "/4" },
        { text: "Item 5" }
      ]

      render_inline(BreadcrumbComponent.new(items: items, collapse: true))

      assert_selector "[data-slot='breadcrumb-ellipsis'] .sr-only", text: "More"
      assert_selector "svg[aria-hidden='true']"
    end

    test "has proper semantic and accessibility structure" do
      items = [
        { text: "Home", path: "/" },
        { text: "Current" }
      ]

      render_inline(BreadcrumbComponent.new(items: items))

      # Semantic nav
      assert_selector "nav[aria-label='breadcrumb']"

      # Proper list structure
      assert_selector "ol"

      # Current page marked
      assert_selector "span[aria-current='page']"

      # Separators hidden from screen readers
      assert_selector "[role='presentation'][aria-hidden='true']"
    end

    test "renders all items as links when none specify current page" do
      items = [
        { text: "Home", path: "/" },
        { text: "Products", path: "/products" },
        { text: "Electronics", path: "/products/electronics" }
      ]

      render_inline(BreadcrumbComponent.new(items: items))

      assert_selector "a[href='/']", text: "Home"
      assert_selector "a[href='/products']", text: "Products"
      assert_selector "a[href='/products/electronics']", text: "Electronics"
      assert_no_selector "[aria-current='page']"
    end
  end
end
