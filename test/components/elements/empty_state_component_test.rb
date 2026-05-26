# frozen_string_literal: true

require "test_helper"

module Elements
  class EmptyStateComponentTest < ViewComponent::TestCase
    test "renders the title inside an h3.empty-state__title" do
      render_inline(EmptyStateComponent.new(icon: "inbox", title: "No items"))

      assert_selector "h3.empty-state__title", text: "No items"
    end

    test "renders the lucide icon inside an .empty-state__icon wrapper with size-10 and txt-subtle classes" do
      render_inline(EmptyStateComponent.new(icon: "inbox", title: "No items"))

      assert_selector ".empty-state__icon svg.size-10.txt-subtle"
    end

    test "renders the description paragraph when description is present" do
      render_inline(EmptyStateComponent.new(icon: "inbox", title: "No items", description: "Try again"))

      assert_selector "p.empty-state__description", text: "Try again"
    end

    test "omits the description paragraph when description is nil" do
      render_inline(EmptyStateComponent.new(icon: "inbox", title: "No items"))

      assert_no_selector "p.empty-state__description"
    end

    test "omits the cta wrapper when no cta slot is provided" do
      render_inline(EmptyStateComponent.new(icon: "inbox", title: "No items"))

      assert_no_selector ".empty-state__cta"
    end

    test "renders the cta slot content inside an .empty-state__cta div" do
      render_inline(EmptyStateComponent.new(icon: "inbox", title: "No items")) do |c|
        c.with_cta { '<a href="/somewhere" class="btn btn--primary">Do it</a>'.html_safe }
      end

      assert_selector ".empty-state__cta a", text: "Do it"
    end

    test "applies the default variant class when no variant is passed" do
      render_inline(EmptyStateComponent.new(icon: "inbox", title: "No items"))

      assert_selector ".empty-state.empty-state--default"
    end

    test "applies the requested variant modifier class for :compact, :inline, :page" do
      %i[compact inline page].each do |variant|
        render_inline(EmptyStateComponent.new(icon: "inbox", title: "No items", variant: variant))

        assert_selector ".empty-state.empty-state--#{variant}"
      end
    end

    test "raises ArgumentError for an invalid variant" do
      error = assert_raises(ArgumentError) do
        EmptyStateComponent.new(icon: "inbox", title: "No items", variant: :nope)
      end

      assert_match(/Unknown variant: nope/, error.message)
    end

    test "merges caller-provided :class with the empty-state classes" do
      render_inline(EmptyStateComponent.new(icon: "inbox", title: "No items", class: "extra-margin"))

      assert_selector ".empty-state.empty-state--default.extra-margin"
    end
  end
end
