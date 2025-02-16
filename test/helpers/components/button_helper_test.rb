require "test_helper"

module Components
  class ButtonHelperTest < ActionView::TestCase
    test "renders a default primary button" do
      rendered = render_button("Click me")
      assert_match "btn btn--primary", rendered
      assert_match "Click me", rendered
    end

    test "renders a secondary button" do
      rendered = render_button("Click me", variant: :secondary)
      assert_match "btn btn--secondary", rendered
    end

    test "renders a danger button" do
      rendered = render_button("Delete", variant: :danger)
      assert_match "btn btn--danger", rendered
    end

    test "renders an outline button" do
      rendered = render_button("Click me", variant: :outline)
      assert_match "btn btn--outline", rendered
    end

    test "renders a plain button" do
      rendered = render_button("Click me", variant: :plain)
      assert_match "btn btn--plain", rendered
    end

    test "renders different size buttons" do
      small = render_button("Small", size: :small)
      medium = render_button("Medium", size: :medium)
      large = render_button("Large", size: :large)

      assert_match "btn--sm", small
      assert_no_match "btn--sm", medium
      assert_match "btn--lg", large
    end

    test "renders as a link" do
      rendered = render_button("Link", as: :link, href: "/path")
      assert_match "href=\"/path\"", rendered
      assert_match "<a", rendered
    end

    test "accepts a block" do
      rendered = render_button do
        "Block content"
      end
      assert_match "Block content", rendered
    end

    test "merges additional classes" do
      rendered = render_button("Click me", class: "custom-class")
      assert_match "btn btn--primary custom-class", rendered
    end
  end
end
