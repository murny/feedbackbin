# frozen_string_literal: true

require "test_helper"

module Ui
  class CardComponentTest < ViewComponent::TestCase
    test "renders basic card with title and content" do
      render_inline(CardComponent.new) do |c|
        c.with_header(title: "Test Title")
        c.with_body { "Test Content" }
      end

      assert_selector "div[data-slot='card']"
      assert_selector "div[data-slot='card-header']"
      assert_selector "div[data-slot='card-title']", text: "Test Title"
      assert_selector "div[data-slot='card-content']", text: "Test Content"
    end

    test "renders card with title and description" do
      render_inline(CardComponent.new) do |c|
        c.with_header(title: "Title", description: "Description")
        c.with_body { "Content" }
      end

      assert_selector "div[data-slot='card-title']", text: "Title"
      assert_selector "div[data-slot='card-description']", text: "Description"
    end

    test "renders card with header action" do
      render_inline(CardComponent.new) do |c|
        c.with_header(title: "Title") { "Action" }
        c.with_body { "Content" }
      end

      assert_selector "div[data-slot='card-action']", text: "Action"
    end

    test "renders card with footer" do
      render_inline(CardComponent.new) do |c|
        c.with_body { "Content" }
        c.with_footer { "Footer Content" }
      end

      assert_selector "div[data-slot='card-footer']", text: "Footer Content"
    end

    test "renders card with all sections" do
      render_inline(CardComponent.new) do |c|
        c.with_header(title: "Title", description: "Description") { "Action" }
        c.with_body { "Content" }
        c.with_footer { "Footer" }
      end

      assert_selector "div[data-slot='card-header']"
      assert_selector "div[data-slot='card-title']", text: "Title"
      assert_selector "div[data-slot='card-description']", text: "Description"
      assert_selector "div[data-slot='card-action']", text: "Action"
      assert_selector "div[data-slot='card-content']", text: "Content"
      assert_selector "div[data-slot='card-footer']", text: "Footer"
    end

    test "renders card with content only" do
      render_inline(CardComponent.new) do |c|
        c.with_body { "Just Content" }
      end

      assert_selector "div[data-slot='card-content']", text: "Just Content"
      assert_no_selector "div[data-slot='card-header']"
      assert_no_selector "div[data-slot='card-footer']"
    end

    test "renders card with custom classes" do
      render_inline(CardComponent.new(class: "custom-class")) do |c|
        c.with_body { "Content" }
      end

      assert_selector "div.custom-class[data-slot='card']"
    end

    test "merges custom classes with base classes" do
      render_inline(CardComponent.new(class: "border-2")) do |c|
        c.with_body { "Content" }
      end

      page_html = page.native.to_html
      assert_includes page_html, "rounded-xl"
      assert_includes page_html, "border-2"
    end

    test "applies data attributes to card" do
      render_inline(CardComponent.new(data: { controller: "test" })) do |c|
        c.with_body { "Content" }
      end

      assert_selector "div[data-controller='test']"
    end

    test "header has correct grid layout classes" do
      render_inline(CardComponent.new) do |c|
        c.with_header(title: "Title") { "Action" }
        c.with_body { "Content" }
      end

      page_html = page.native.to_html
      assert_includes page_html, "grid-cols-[1fr_auto]"
      assert_includes page_html, "@container/card-header"
    end

    test "renders without header when not provided" do
      render_inline(CardComponent.new) do |c|
        c.with_body { "Content" }
        c.with_footer { "Footer" }
      end

      assert_no_selector "div[data-slot='card-header']"
      assert_selector "div[data-slot='card-content']"
      assert_selector "div[data-slot='card-footer']"
    end

    test "renders without footer when not provided" do
      render_inline(CardComponent.new) do |c|
        c.with_header(title: "Title")
        c.with_body { "Content" }
      end

      assert_selector "div[data-slot='card-header']"
      assert_selector "div[data-slot='card-content']"
      assert_no_selector "div[data-slot='card-footer']"
    end

    test "header without action does not render action slot" do
      render_inline(CardComponent.new) do |c|
        c.with_header(title: "Title")
        c.with_body { "Content" }
      end

      assert_no_selector "div[data-slot='card-action']"
    end

    test "supports custom content classes" do
      render_inline(CardComponent.new) do |c|
        c.with_body(class: "custom-content") { "Content" }
      end

      assert_selector "div.custom-content[data-slot='card-content']"
    end

    test "supports custom footer classes" do
      render_inline(CardComponent.new) do |c|
        c.with_body { "Content" }
        c.with_footer(class: "custom-footer") { "Footer" }
      end

      assert_selector "div.custom-footer[data-slot='card-footer']"
    end

    test "includes base card styling classes" do
      render_inline(CardComponent.new) do |c|
        c.with_body { "Content" }
      end

      page_html = page.native.to_html
      assert_includes page_html, "bg-card"
      assert_includes page_html, "rounded-xl"
      assert_includes page_html, "border"
      assert_includes page_html, "shadow-sm"
    end

    test "header has correct padding classes" do
      render_inline(CardComponent.new) do |c|
        c.with_header(title: "Title")
        c.with_body { "Content" }
      end

      page_html = page.native.to_html
      assert_includes page_html, "px-6"
    end

    test "content has correct padding classes" do
      render_inline(CardComponent.new) do |c|
        c.with_body { "Content" }
      end

      page_html = page.native.to_html
      assert_includes page_html, "px-6"
    end

    test "footer has correct padding and alignment classes" do
      render_inline(CardComponent.new) do |c|
        c.with_body { "Content" }
        c.with_footer { "Footer" }
      end

      page_html = page.native.to_html
      assert_includes page_html, "px-6"
      assert_includes page_html, "flex"
      assert_includes page_html, "items-center"
    end

    test "supports custom header classes" do
      render_inline(CardComponent.new) do |c|
        c.with_header(title: "Title", class: "custom-header")
        c.with_body { "Content" }
      end

      assert_selector "div.custom-header[data-slot='card-header']"
    end

    test "supports custom data attributes on header" do
      render_inline(CardComponent.new) do |c|
        c.with_header(title: "Title", data: { action: "click->test#handle" })
        c.with_body { "Content" }
      end

      assert_selector "div[data-slot='card-header'][data-action='click->test#handle']"
    end

    test "supports custom data attributes on content" do
      render_inline(CardComponent.new) do |c|
        c.with_body(data: { controller: "content-test" }) { "Content" }
      end

      assert_selector "div[data-slot='card-content'][data-controller='content-test']"
    end

    test "supports custom data attributes on footer" do
      render_inline(CardComponent.new) do |c|
        c.with_body { "Content" }
        c.with_footer(data: { controller: "footer-test" }) { "Footer" }
      end

      assert_selector "div[data-slot='card-footer'][data-controller='footer-test']"
    end
  end
end
