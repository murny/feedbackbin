# frozen_string_literal: true

module OrganizationsHelper
  def organization_logo(organization, size: :large, **options)
    size_config = organization_logo_size_config(size)
    custom_classes = options[:class]

    if organization.logo.attached?
      image_tag organization.logo,
        class: "#{size_config[:image_classes]} #{custom_classes}".strip,
        alt: organization.name
    else
      tag.div organization.name[0..1].upcase,
        class: "#{size_config[:fallback_classes]} #{custom_classes}".strip
    end
  end

  private

    def organization_logo_size_config(size)
      case size
      when :small
        {
          image_classes: "h-4 w-4 rounded-sm object-cover flex-shrink-0",
          fallback_classes: "h-4 w-4 rounded-sm bg-muted text-muted-foreground text-xs font-medium flex items-center justify-center flex-shrink-0"
        }
      when :medium
        {
          image_classes: "h-5 w-5 rounded-sm object-cover flex-shrink-0",
          fallback_classes: "h-5 w-5 rounded-sm bg-muted text-muted-foreground text-xs font-medium flex items-center justify-center flex-shrink-0"
        }
      when :large
        {
          image_classes: "rounded-lg size-12 object-cover",
          fallback_classes: "size-12 rounded-lg bg-primary text-primary-foreground text-sm font-medium flex items-center justify-center"
        }
      else
        raise ArgumentError, "Unknown logo size: #{size}. Use :small, :medium, or :large"
      end
    end
end
