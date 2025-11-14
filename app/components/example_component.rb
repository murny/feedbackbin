# frozen_string_literal: true

class ExampleComponent < ViewComponent::Base
  def initialize(text:)
    @text = text
  end
end
