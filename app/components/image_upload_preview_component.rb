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
    image_class: "h-20 w-20 flex-none rounded-lg bg-muted object-cover border",
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
    # Style the label to look like a button
    base = "inline-flex items-center justify-center gap-2 whitespace-nowrap rounded-md text-sm font-medium transition-all shrink-0 outline-hidden cursor-pointer"
    focus = "focus-visible:border-ring focus-visible:ring-ring/50 focus-visible:ring-[3px]"
    icons = "[&_svg]:pointer-events-none [&_svg:not([class*='size-'])]:size-4 [&_svg]:shrink-0"
    size = "h-9 px-4 py-2"

    variant = case upload_button_variant
    when :default
      "bg-primary text-primary-foreground shadow-xs hover:bg-primary/90"
    when :destructive
      "bg-destructive text-white shadow-xs hover:bg-destructive/90"
    when :outline
      "border bg-background shadow-xs hover:bg-accent hover:text-accent-foreground"
    when :secondary
      "bg-secondary text-secondary-foreground shadow-xs hover:bg-secondary/80"
    when :ghost
      "hover:bg-accent hover:text-accent-foreground"
    else
      "bg-secondary text-secondary-foreground shadow-xs hover:bg-secondary/80"
    end

    tw_merge(base, focus, icons, size, variant)
  end
end
