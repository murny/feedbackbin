# frozen_string_literal: true

require "test_helper"

module Elements
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

    test "raises error when rendered without content" do
      error = assert_raises(ArgumentError) do
        render_inline(BadgeComponent.new)
      end

      assert_equal "Badge content cannot be empty", error.message
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
        "<svg></svg>With Icon".html_safe
      end

      assert_selector "span svg"
      assert_text "With Icon"
    end

    test "default variant has primary class" do
      render_inline(BadgeComponent.new(variant: :default)) { "Test" }

      assert_selector "span.badge--primary"
    end

    test "secondary variant has secondary class" do
      render_inline(BadgeComponent.new(variant: :secondary)) { "Test" }

      assert_selector "span.badge--secondary"
    end

    test "destructive variant has destructive class" do
      render_inline(BadgeComponent.new(variant: :destructive)) { "Test" }

      assert_selector "span.badge--destructive"
    end

    test "outline variant has outline class" do
      render_inline(BadgeComponent.new(variant: :outline)) { "Test" }

      assert_selector "span.badge--outline"
      assert_no_selector "span.badge--primary"
      assert_no_selector "span.badge--secondary"
      assert_no_selector "span.badge--destructive"
    end

    test "color: defaults tone to :solid and inlines --badge-color-source" do
      render_inline(BadgeComponent.new(color: "#10b981")) { "Test" }

      assert_selector "span.badge--solid"
      assert_selector "span[style*='--badge-color-source: #10b981']"
      assert_no_selector "span.badge--primary"
    end

    test "color: with tone :soft applies soft class and inlines source" do
      render_inline(BadgeComponent.new(color: "#8b5cf6", tone: :soft)) { "Test" }

      assert_selector "span.badge--soft"
      assert_selector "span[style*='--badge-color-source: #8b5cf6']"
    end

    test "color: merges with caller-provided style" do
      render_inline(BadgeComponent.new(color: "#10b981", style: "margin-inline-start: 1rem;")) { "Test" }

      assert_selector "span[style*='--badge-color-source: #10b981']"
      assert_selector "span[style*='margin-inline-start: 1rem']"
    end

    test "passing both variant: and color: raises ArgumentError" do
      error = assert_raises(ArgumentError) do
        BadgeComponent.new(variant: :secondary, color: "#10b981")
      end

      assert_match(/variant: \(semantic\) OR color: \(runtime\), not both/, error.message)
    end

    test "passing tone: without color: raises ArgumentError" do
      error = assert_raises(ArgumentError) do
        BadgeComponent.new(tone: :soft)
      end

      assert_match(/tone: is only valid with color:/, error.message)
    end

    test "with_dot: true adds badge--with-dot modifier" do
      render_inline(BadgeComponent.new(color: "#3b82f6", tone: :soft, with_dot: true)) { "Test" }

      assert_selector "span.badge--with-dot"
      assert_selector "span.badge--soft"
    end

    test "with_dot: false (default) omits the dot modifier" do
      render_inline(BadgeComponent.new(color: "#3b82f6", tone: :soft)) { "Test" }

      assert_no_selector "span.badge--with-dot"
    end

    test "without color: does not inject --badge-color-source into style" do
      render_inline(BadgeComponent.new(variant: :secondary)) { "Test" }

      assert_no_selector "span[style*='--badge-color-source']"
    end

    test "invalid tone raises ArgumentError" do
      assert_raises(ArgumentError) do
        BadgeComponent.new(color: "#abc", tone: :neon)
      end
    end
  end
end
