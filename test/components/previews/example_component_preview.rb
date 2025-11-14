# frozen_string_literal: true

class ExampleComponentPreview < ViewComponent::Preview
  # @label Default
  def default
    render(ExampleComponent.new(text: "Hello from ViewComponent!"))
  end

  # @label Welcome Message
  def welcome
    render(ExampleComponent.new(text: "Welcome to Lookbook + ViewComponent"))
  end

  # @label Custom Text
  # @param text text "Custom text to display"
  def custom(text: "Your custom text here")
    render(ExampleComponent.new(text: text))
  end
end
