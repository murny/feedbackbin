# frozen_string_literal: true

class ImageUploadPreviewComponent < Elements::BaseComponent
  attr_reader :form, :field_name, :preview_url, :upload_button_text, :size_hint,
              :image_class, :upload_button_variant, :remove_path, :remove_confirmation

  def initialize(
    form:,
    field_name:,
    preview_url:,
    upload_button_text:,
    size_hint:,
    image_class: "upload-preview__image",
    upload_button_variant: :secondary,
    remove_path: nil,
    remove_confirmation: nil
  )
    @form = form
    @field_name = field_name
    @preview_url = preview_url
    @upload_button_text = upload_button_text
    @size_hint = size_hint
    @image_class = image_class
    @upload_button_variant = upload_button_variant
    @remove_path = remove_path
    @remove_confirmation = remove_confirmation
  end

  def show_remove_button?
    remove_path.present?
  end

  def button_classes
    variant_class = case upload_button_variant
    when :default, :primary then "btn--primary"
    when :destructive then "btn--destructive"
    when :outline then "btn--outline"
    when :secondary then "btn--secondary"
    when :ghost then "btn--ghost"
    else "btn--secondary"
    end

    ["btn", variant_class].join(" ")
  end
end
