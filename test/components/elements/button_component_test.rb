# frozen_string_literal: true

require "test_helper"

module Elements
  class ButtonComponentTest < ViewComponent::TestCase
    test "renders default button" do
      render_inline(ButtonComponent.new) { "Click me" }

      assert_selector "button", text: "Click me"
      assert_selector "button[type='button']"
    end

    test "renders all variants without errors" do
      ButtonComponent::VARIANTS.each do |variant|
        render_inline(ButtonComponent.new(variant: variant)) { "Test" }

        assert_selector "button, a"
      end
    end

    test "renders all sizes without errors" do
      ButtonComponent::SIZES.each do |size|
        render_inline(ButtonComponent.new(size: size)) { "Test" }

        assert_selector "button, a"
      end
    end

    test "renders as link when href provided" do
      render_inline(ButtonComponent.new(href: "/test")) { "Link" }

      assert_selector "a[href='/test']", text: "Link"
      assert_no_selector "button"
    end

    test "renders as button when no href" do
      render_inline(ButtonComponent.new) { "Button" }

      assert_selector "button", text: "Button"
      assert_no_selector "a"
    end

    test "shows loading state when loading" do
      render_inline(ButtonComponent.new(loading: true)) { "Loading" }

      assert_selector "button.btn--loading"
      assert_selector "button[disabled]"
    end

    test "uses aria-disabled for links when loading" do
      render_inline(ButtonComponent.new(href: "/test", loading: true)) { "Loading" }

      assert_selector "a[href='/test'][aria-disabled='true']"
      assert_no_selector "a[disabled]"
    end

    test "uses aria-disabled for links when disabled" do
      render_inline(ButtonComponent.new(href: "/test", disabled: true)) { "Disabled Link" }

      assert_selector "a[href='/test'][aria-disabled='true']"
      assert_no_selector "a[disabled]"
    end

    test "adds aria-busy to buttons when loading" do
      render_inline(ButtonComponent.new(loading: true)) { "Loading" }

      assert_selector "button[aria-busy='true']"
    end

    test "adds aria-busy to links when loading" do
      render_inline(ButtonComponent.new(href: "/test", loading: true)) { "Loading" }

      assert_selector "a[aria-busy='true']"
    end

    test "merges custom classes" do
      render_inline(ButtonComponent.new(class: "custom-class")) { "Test" }

      assert_selector "button.custom-class"
    end

    test "sets disabled attribute" do
      render_inline(ButtonComponent.new(disabled: true)) { "Test" }

      assert_selector "button[disabled]"
    end

    test "sets custom type attribute" do
      render_inline(ButtonComponent.new(type: :submit)) { "Submit" }

      assert_selector "button[type='submit']"
    end

    test "raises error for invalid variant" do
      assert_raises(ArgumentError) do
        ButtonComponent.new(variant: :invalid)
      end
    end

    test "raises error for invalid size" do
      assert_raises(ArgumentError) do
        ButtonComponent.new(size: :invalid)
      end
    end

    test "includes base btn class" do
      render_inline(ButtonComponent.new) { "Test" }

      assert_selector "button.btn"
    end

    test "works with data attributes" do
      render_inline(ButtonComponent.new(data: { action: "click->test#handler" })) { "Test" }

      assert_selector "button[data-action='click->test#handler']"
    end
  end
end
