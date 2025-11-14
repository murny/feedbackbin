# frozen_string_literal: true

require "test_helper"

module Ui
  class BadgeComponentTest < ViewComponent::TestCase
    test "renders default badge as span" do
      render_inline(BadgeComponent.new) { "Test Badge" }

      assert_selector "span", text: "Test Badge"
    end

    test "renders all variants" do
      BadgeComponent::VARIANTS.each do |variant|
        render_inline(BadgeComponent.new(variant: variant)) { "Test" }

        assert_selector "span, a"
      end
    end

    test "renders as link when href provided" do
      render_inline(BadgeComponent.new(href: "/test")) { "Link Badge" }

      assert_selector "a[href='/test']", text: "Link Badge"
    end

    test "renders with text parameter (legacy support)" do
      render_inline(BadgeComponent.new(text: "Legacy Text"))

      assert_selector "span", text: "Legacy Text"
    end

    test "prefers block content over text parameter" do
      render_inline(BadgeComponent.new(text: "Text Param")) { "Block Content" }

      assert_selector "span", text: "Block Content"
      assert_no_selector "span", text: "Text Param"
    end

    test "merges custom classes" do
      render_inline(BadgeComponent.new(class: "custom-class")) { "Test" }

      assert_selector "span.custom-class"
    end

    test "applies custom styles" do
      render_inline(BadgeComponent.new(style: "background-color: red;")) { "Test" }

      assert_selector "span[style='background-color: red;']"
    end

    test "includes data attributes" do
      render_inline(BadgeComponent.new(data: { test: "value" })) { "Test" }

      assert_selector "span[data-test='value']"
    end

    test "raises error for invalid variant" do
      assert_raises(ArgumentError) do
        BadgeComponent.new(variant: :invalid)
      end
    end

    test "renders with icon content" do
      render_inline(BadgeComponent.new) do
        '<svg></svg>With Icon'.html_safe
      end

      assert_selector "span svg"
      assert_text "With Icon"
    end

    test "default variant has primary background" do
      render_inline(BadgeComponent.new(variant: :default)) { "Test" }

      assert_selector "span[class*='bg-primary']"
    end

    test "secondary variant has secondary background" do
      render_inline(BadgeComponent.new(variant: :secondary)) { "Test" }

      assert_selector "span[class*='bg-secondary']"
    end

    test "destructive variant has destructive background" do
      render_inline(BadgeComponent.new(variant: :destructive)) { "Test" }

      assert_selector "span[class*='bg-destructive']"
    end

    test "outline variant has no background" do
      render_inline(BadgeComponent.new(variant: :outline)) { "Test" }

      assert_no_selector "span[class*='bg-primary']"
      assert_no_selector "span[class*='bg-secondary']"
      assert_no_selector "span[class*='bg-destructive']"
    end
  end
end
