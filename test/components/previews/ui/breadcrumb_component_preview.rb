# frozen_string_literal: true

module Ui
  # @label Breadcrumb
  class BreadcrumbComponentPreview < ViewComponent::Preview
    # @label Default
    def default
      render Ui::BreadcrumbComponent.new(
        items: [
          { text: "Home", path: "/" },
          { text: "Products", path: "/products" },
          { text: "Electronics" }
        ]
      )
    end

    # @label Long Path
    def long_path
      render Ui::BreadcrumbComponent.new(
        items: [
          { text: "Home", path: "/" },
          { text: "Products", path: "/products" },
          { text: "Electronics", path: "/products/electronics" },
          { text: "Computers", path: "/products/electronics/computers" },
          { text: "Laptops", path: "/products/electronics/computers/laptops" },
          { text: "Gaming Laptops" }
        ]
      )
    end

    # @label Collapsed
    def collapsed
      render Ui::BreadcrumbComponent.new(
        items: [
          { text: "Home", path: "/" },
          { text: "Products", path: "/products" },
          { text: "Electronics", path: "/products/electronics" },
          { text: "Computers", path: "/products/electronics/computers" },
          { text: "Laptops", path: "/products/electronics/computers/laptops" },
          { text: "Gaming Laptops" }
        ],
        collapse: true
      )
    end

    # @label Custom Separator (Text)
    def custom_separator_text
      render_with_template
    end

    # @label Custom Separator (Icon)
    def custom_separator_icon
      render_with_template
    end

    # @label Two Items
    def two_items
      render Ui::BreadcrumbComponent.new(
        items: [
          { text: "Home", path: "/" },
          { text: "Current Page" }
        ]
      )
    end

    # @label Single Item
    def single_item
      render Ui::BreadcrumbComponent.new(
        items: [
          { text: "Home" }
        ]
      )
    end

    # @label All Links (No Current)
    # Shows all items as links - useful when breadcrumb is above page title
    def all_links
      render Ui::BreadcrumbComponent.new(
        items: [
          { text: "Home", path: "/" },
          { text: "Products", path: "/products" },
          { text: "Electronics", path: "/products/electronics" }
        ]
      )
    end
  end
end
