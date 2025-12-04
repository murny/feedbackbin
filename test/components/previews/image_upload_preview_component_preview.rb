# frozen_string_literal: true

# @label Image Upload Preview
class ImageUploadPreviewComponentPreview < ViewComponent::Preview
  # @label Default
  def default
    render_with_template
  end

  # @label With Remove Button
  def with_remove_button
    render_with_template
  end

  # @label Button Variants
  def button_variants
    render_with_template
  end

  # @label Custom Image Size
  def custom_image_size
    render_with_template
  end
end
