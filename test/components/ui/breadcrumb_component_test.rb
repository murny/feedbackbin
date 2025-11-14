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
      assert_selector "ol[data-slot='breadcrumb-list']"
      assert_selector "li[data-slot='breadcrumb-item']", count: 3
    end

    test "renders links for items with path" do
      items = [
        { text: "Home", path: "/" },
        { text: "Products", path: "/products" },
        { text: "Current" }
      ]

      render_inline(BreadcrumbComponent.new(items: items))

      assert_selector "a[href='/'][data-slot='breadcrumb-link']", text: "Home"
      assert_selector "a[href='/products'][data-slot='breadcrumb-link']", text: "Products"
    end

    test "renders last item as current page (no link)" do
      items = [
        { text: "Home", path: "/" },
        { text: "Current" }
      ]

      render_inline(BreadcrumbComponent.new(items: items))

      assert_selector "span[data-slot='breadcrumb-page'][aria-current='page']", text: "Current"
      assert_no_selector "a", text: "Current"
    end

    test "renders separators between items" do
      items = [
        { text: "Home", path: "/" },
        { text: "Products", path: "/products" },
        { text: "Current" }
      ]

      render_inline(BreadcrumbComponent.new(items: items))

      # Should have 2 separators for 3 items
      assert_selector "li[data-slot='breadcrumb-separator']", count: 2
    end

    test "does not render separator after last item" do
      items = [
        { text: "Home", path: "/" },
        { text: "Current" }
      ]

      render_inline(BreadcrumbComponent.new(items: items))

      # Should have 1 separator for 2 items
      assert_selector "li[data-slot='breadcrumb-separator']", count: 1
    end

    test "renders default chevron-right separator" do
      items = [
        { text: "Home", path: "/" },
        { text: "Current" }
      ]

      render_inline(BreadcrumbComponent.new(items: items))

      # Check for chevron-right icon (lucide icon)
      assert_selector "li[data-slot='breadcrumb-separator'] svg"
    end

    test "renders custom text separator" do
      items = [
        { text: "Home", path: "/" },
        { text: "Current" }
      ]

      render_inline(BreadcrumbComponent.new(items: items, separator: " / "))

      assert_text " / "
    end

    test "collapses long breadcrumb when collapse is true" do
      items = [
        { text: "Item 1", path: "/1" },
        { text: "Item 2", path: "/2" },
        { text: "Item 3", path: "/3" },
        { text: "Item 4", path: "/4" },
        { text: "Item 5" }
      ]

      render_inline(BreadcrumbComponent.new(items: items, collapse: true))

      # Should show: first, ellipsis, last (3 items total)
      assert_selector "li[data-slot='breadcrumb-item']", count: 3
      assert_selector "span[data-slot='breadcrumb-ellipsis']"
      assert_selector "a", text: "Item 1" # First
      assert_selector "span[data-slot='breadcrumb-page']", text: "Item 5" # Last
      assert_no_selector "a", text: "Item 2"
      assert_no_selector "a", text: "Item 3"
      assert_no_selector "a", text: "Item 4"
    end

    test "does not collapse when 3 or fewer items" do
      items = [
        { text: "Item 1", path: "/1" },
        { text: "Item 2", path: "/2" },
        { text: "Item 3" }
      ]

      render_inline(BreadcrumbComponent.new(items: items, collapse: true))

      # All items should be visible
      assert_selector "li[data-slot='breadcrumb-item']", count: 3
      assert_no_selector "span[data-slot='breadcrumb-ellipsis']"
    end

    test "ellipsis has screen reader text" do
      items = 5.times.map { |i| { text: "Item #{i + 1}", path: "/#{i + 1}" } }
      items.last.delete(:path) # Make last item current

      render_inline(BreadcrumbComponent.new(items: items, collapse: true))

      assert_selector "span[data-slot='breadcrumb-ellipsis'] .sr-only", text: "More"
    end

    test "renders single item without separator" do
      items = [{ text: "Home" }]

      render_inline(BreadcrumbComponent.new(items: items))

      assert_selector "li[data-slot='breadcrumb-item']", count: 1
      assert_no_selector "li[data-slot='breadcrumb-separator']"
    end

    test "item with path at non-last position renders as link" do
      items = [
        { text: "Home", path: "/" },
        { text: "Middle", path: "/middle" },
        { text: "Current" }
      ]

      render_inline(BreadcrumbComponent.new(items: items))

      assert_selector "a[href='/middle']", text: "Middle"
    end

    test "merges custom classes" do
      items = [{ text: "Home" }]

      render_inline(BreadcrumbComponent.new(items: items, class: "custom-class"))

      page_html = page.native.to_html
      assert_includes page_html, "custom-class"
    end

    test "includes accessibility attributes" do
      items = [
        { text: "Home", path: "/" },
        { text: "Current" }
      ]

      render_inline(BreadcrumbComponent.new(items: items))

      assert_selector "nav[aria-label='breadcrumb']"
      assert_selector "span[aria-current='page'][aria-disabled='true']"
      assert_selector "li[role='presentation'][aria-hidden='true'][data-slot='breadcrumb-separator']"
    end

    test "applies responsive gap classes" do
      items = [{ text: "Home" }]

      render_inline(BreadcrumbComponent.new(items: items))

      page_html = page.native.to_html
      assert_includes page_html, "gap-1.5"
      assert_includes page_html, "sm:gap-2.5"
    end

    test "all items can be links when no current page" do
      items = [
        { text: "Home", path: "/" },
        { text: "Products", path: "/products" },
        { text: "Electronics", path: "/products/electronics" }
      ]

      render_inline(BreadcrumbComponent.new(items: items))

      # All items should be links
      assert_selector "a[href='/']", text: "Home"
      assert_selector "a[href='/products']", text: "Products"
      assert_selector "a[href='/products/electronics']", text: "Electronics"
      assert_no_selector "span[data-slot='breadcrumb-page']"
    end

    test "item without path at last position renders as current page" do
      items = [
        { text: "Home", path: "/" },
        { text: "Current" }
      ]

      render_inline(BreadcrumbComponent.new(items: items))

      assert_selector "span[data-slot='breadcrumb-page']", text: "Current"
      assert_no_selector "a", text: "Current"
    end

    test "applies data-slot attributes correctly" do
      items = [
        { text: "Home", path: "/" },
        { text: "Current" }
      ]

      render_inline(BreadcrumbComponent.new(items: items))

      assert_selector "nav[data-slot='breadcrumb']"
      assert_selector "ol[data-slot='breadcrumb-list']"
      assert_selector "li[data-slot='breadcrumb-item']"
      assert_selector "a[data-slot='breadcrumb-link']"
      assert_selector "span[data-slot='breadcrumb-page']"
      assert_selector "li[data-slot='breadcrumb-separator']"
    end

    test "collapsed breadcrumb has correct separator count" do
      items = 5.times.map { |i| { text: "Item #{i + 1}", path: "/#{i + 1}" } }
      items.last.delete(:path)

      render_inline(BreadcrumbComponent.new(items: items, collapse: true))

      # Should have 2 separators: first | ellipsis | last
      assert_selector "li[data-slot='breadcrumb-separator']", count: 2
    end
  end
end
