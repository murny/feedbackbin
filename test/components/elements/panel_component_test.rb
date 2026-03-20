# frozen_string_literal: true

require "test_helper"

module Elements
  class PanelComponentTest < ViewComponent::TestCase
    test "renders basic panel with title and content" do
      render_inline(PanelComponent.new) do |c|
        c.with_header(title: "Test Title")
        c.with_body { "Test Content" }
      end

      assert_selector "div[data-slot='panel']"
      assert_selector "header[data-slot='panel-header']"
      assert_selector "h2[data-slot='panel-title']", text: "Test Title"
      assert_selector "section[data-slot='panel-content']", text: "Test Content"
    end

    test "renders panel with title and description" do
      render_inline(PanelComponent.new) do |c|
        c.with_header(title: "Title", description: "Description")
        c.with_body { "Content" }
      end

      assert_selector "h2[data-slot='panel-title']", text: "Title"
      assert_selector "p[data-slot='panel-description']", text: "Description"
    end

    test "renders panel with header action" do
      render_inline(PanelComponent.new) do |c|
        c.with_header(title: "Title") { "Action" }
        c.with_body { "Content" }
      end

      assert_selector "div[data-slot='panel-action']", text: "Action"
    end

    test "renders panel with footer" do
      render_inline(PanelComponent.new) do |c|
        c.with_body { "Content" }
        c.with_footer { "Footer Content" }
      end

      assert_selector "footer[data-slot='panel-footer']", text: "Footer Content"
    end

    test "renders panel with all sections" do
      render_inline(PanelComponent.new) do |c|
        c.with_header(title: "Title", description: "Description") { "Action" }
        c.with_body { "Content" }
        c.with_footer { "Footer" }
      end

      assert_selector "header[data-slot='panel-header']"
      assert_selector "h2[data-slot='panel-title']", text: "Title"
      assert_selector "p[data-slot='panel-description']", text: "Description"
      assert_selector "div[data-slot='panel-action']", text: "Action"
      assert_selector "section[data-slot='panel-content']", text: "Content"
      assert_selector "footer[data-slot='panel-footer']", text: "Footer"
    end

    test "renders panel with content only" do
      render_inline(PanelComponent.new) do |c|
        c.with_body { "Just Content" }
      end

      assert_selector "section[data-slot='panel-content']", text: "Just Content"
      assert_no_selector "header[data-slot='panel-header']"
      assert_no_selector "footer[data-slot='panel-footer']"
    end

    test "renders panel with custom classes" do
      render_inline(PanelComponent.new(class: "custom-class")) do |c|
        c.with_body { "Content" }
      end

      assert_selector "div.custom-class[data-slot='panel']"
    end

    test "merges custom classes with base classes" do
      render_inline(PanelComponent.new(class: "border-2")) do |c|
        c.with_body { "Content" }
      end

      assert_selector "div[data-slot='panel'].panel.border-2"
    end

    test "applies data attributes to panel" do
      render_inline(PanelComponent.new(data: { controller: "test" })) do |c|
        c.with_body { "Content" }
      end

      assert_selector "div[data-controller='test']"
    end

    test "header has panel__header class" do
      render_inline(PanelComponent.new) do |c|
        c.with_header(title: "Title") { "Action" }
        c.with_body { "Content" }
      end

      assert_selector "header.panel__header[data-slot='panel-header']"
    end

    test "renders without header when not provided" do
      render_inline(PanelComponent.new) do |c|
        c.with_body { "Content" }
        c.with_footer { "Footer" }
      end

      assert_no_selector "header[data-slot='panel-header']"
      assert_selector "section[data-slot='panel-content']"
      assert_selector "footer[data-slot='panel-footer']"
    end

    test "renders without footer when not provided" do
      render_inline(PanelComponent.new) do |c|
        c.with_header(title: "Title")
        c.with_body { "Content" }
      end

      assert_selector "header[data-slot='panel-header']"
      assert_selector "section[data-slot='panel-content']"
      assert_no_selector "footer[data-slot='panel-footer']"
    end

    test "header without action does not render action slot" do
      render_inline(PanelComponent.new) do |c|
        c.with_header(title: "Title")
        c.with_body { "Content" }
      end

      assert_no_selector "div[data-slot='panel-action']"
    end

    test "supports custom content classes" do
      render_inline(PanelComponent.new) do |c|
        c.with_body(class: "custom-content") { "Content" }
      end

      assert_selector "section.custom-content[data-slot='panel-content']"
    end

    test "supports custom footer classes" do
      render_inline(PanelComponent.new) do |c|
        c.with_body { "Content" }
        c.with_footer(class: "custom-footer") { "Footer" }
      end

      assert_selector "footer.custom-footer[data-slot='panel-footer']"
    end

    test "includes base panel styling class" do
      render_inline(PanelComponent.new) do |c|
        c.with_body { "Content" }
      end

      assert_selector "div[data-slot='panel'].panel"
    end

    test "header has correct classes" do
      render_inline(PanelComponent.new) do |c|
        c.with_header(title: "Title")
        c.with_body { "Content" }
      end

      assert_selector "header[data-slot='panel-header'].panel__header"
    end

    test "content has correct classes" do
      render_inline(PanelComponent.new) do |c|
        c.with_body { "Content" }
      end

      assert_selector "section[data-slot='panel-content'].panel__body"
    end

    test "footer has correct classes" do
      render_inline(PanelComponent.new) do |c|
        c.with_body { "Content" }
        c.with_footer { "Footer" }
      end

      assert_selector "footer[data-slot='panel-footer'].panel__footer"
    end

    test "supports custom header classes" do
      render_inline(PanelComponent.new) do |c|
        c.with_header(title: "Title", class: "custom-header")
        c.with_body { "Content" }
      end

      assert_selector "header.custom-header[data-slot='panel-header']"
    end

    test "supports custom data attributes on header" do
      render_inline(PanelComponent.new) do |c|
        c.with_header(title: "Title", data: { action: "click->test#handle" })
        c.with_body { "Content" }
      end

      assert_selector "header[data-slot='panel-header'][data-action='click->test#handle']"
    end

    test "supports custom data attributes on content" do
      render_inline(PanelComponent.new) do |c|
        c.with_body(data: { controller: "content-test" }) { "Content" }
      end

      assert_selector "section[data-slot='panel-content'][data-controller='content-test']"
    end

    test "supports custom data attributes on footer" do
      render_inline(PanelComponent.new) do |c|
        c.with_body { "Content" }
        c.with_footer(data: { controller: "footer-test" }) { "Footer" }
      end

      assert_selector "footer[data-slot='panel-footer'][data-controller='footer-test']"
    end

    test "header with action only (no title/description) renders without empty text container" do
      render_inline(PanelComponent.new) do |c|
        c.with_header { "Action Only" }
        c.with_body { "Content" }
      end

      assert_selector "header[data-slot='panel-header']"
      assert_selector "div[data-slot='panel-action']", text: "Action Only"
      assert_no_selector "h2[data-slot='panel-title']"
      assert_no_selector "p[data-slot='panel-description']"
    end
  end
end
