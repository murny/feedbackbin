# frozen_string_literal: true

require "test_helper"

class ExampleComponentTest < ViewComponent::TestCase
  def test_component_renders_something_useful
    render_inline(ExampleComponent.new(text: "Hello, components!"))

    assert_selector "div.p-4.bg-primary.text-primary-foreground.rounded-lg", text: "Hello, components!"
  end
end
