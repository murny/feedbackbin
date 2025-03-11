# frozen_string_literal: true

module Organizations
  module LogosHelper
    # Reuse the same color array from AvatarsHelper for consistency
    LOGO_COLORS = Users::AvatarsHelper::AVATAR_COLORS

    # Returns the background color for the organization's logo using a deterministic algorithm
    def organization_background_color(organization)
      LOGO_COLORS[Zlib.crc32(organization.to_param) % LOGO_COLORS.size]
    end

    # Renders organization logo or a fallback with initials
    def organization_logo_tag(organization, **options)
      if organization.logo.present?
        image_tag organization.logo, alt: organization.name, **options
      else
        content_tag :span, class: "inline-grid h-full w-full items-center justify-center bg-[#{organization_background_color(organization)}] text-white" do
          content_tag :span, class: options[:initial_classes] || "text-sm font-medium uppercase" do
            organization.name[0..1]
          end
        end
      end
    end
  end
end
