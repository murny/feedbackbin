# frozen_string_literal: true

module BrandingHelper
  # Generate Open Graph image URL for the organization
  # Falls back to logo, then to default icon
  def organization_og_image_url(organization)
    if organization.og_image.attached?
      url_for(organization.og_image)
    elsif organization.logo.attached?
      url_for(organization.logo)
    else
      # Return full URL to default icon
      asset_url("/icon.png")
    end
  end

  # Generate preview URL for an attachment with fallback
  # @param attachment [ActiveStorage::Attached::One] The attachment to preview
  # @param variant_options [Hash] Options for ActiveStorage variant (e.g., resize_to_limit: [96, 96])
  # @param default_url [String] URL to use if attachment is not present
  # @return [String] The preview URL
  def attachment_preview_url(attachment, variant_options: nil, default_url: "/icon.svg")
    # Check if attachment is attached AND persisted (has a blob saved to database)
    # Unpersisted attachments (e.g., from failed validations) cannot generate signed URLs
    if attachment.attached? && attachment.blob.persisted?
      if variant_options
        rails_representation_url(attachment.variant(variant_options))
      else
        url_for(attachment)
      end
    else
      default_url
    end
  end

  # Logo link URL
  # Returns organization's logo_link or root_path as fallback
  def branded_logo_url
    Current.organization&.logo_link.presence || root_path
  end

  # Branded logo image
  # Returns organization logo or default FeedbackBin mark
  # @param options [Hash] HTML options to pass to the image/svg tag
  def branded_logo(**options)
    if Current.organization
      organization_logo(Current.organization, **options)
    else
      inline_svg_tag("mark.svg", **options)
    end
  end

  # Brand name
  # Returns organization name or default brand name
  def brand_name
    Current.organization&.name || t("application.navbar.brand_name")
  end

  # Whether to show the brand name
  # Returns true if no organization or organization wants to show name
  def show_brand_name?
    Current.organization.nil? || Current.organization.show_company_name?
  end
end
