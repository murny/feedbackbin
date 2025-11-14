# frozen_string_literal: true

require "test_helper"

class ExampleComponentTest < ViewComponent::TestCase
  def test_component_renders_something_useful
    assert_equal(
      %(<div class="p-4 bg-primary text-primary-foreground rounded-lg">Hello, components!</div>),
      render_inline(ExampleComponent.new(text: "Hello, components!")).css("div").to_html
    )
  end
end
