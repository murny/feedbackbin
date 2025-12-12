# frozen_string_literal: true

module BrandingHelper
  # Generate Open Graph image URL for the account
  # Falls back to logo, then to default icon
  def account_og_image_url(account)
    return asset_url("/icon.png") unless account

    if account.og_image.attached?
      url_for(account.og_image)
    elsif account.logo.attached?
      url_for(account.logo)
    else
      asset_url("/icon.png")
    end
  end

  # Generate preview URL for an attachment with fallback
  # @param attachment [ActiveStorage::Attached::One] The attachment to preview
  # @param variant_options [Hash] Options for ActiveStorage variant (e.g., resize_to_limit: [96, 96])
  # @param default_url [String] URL to use if attachment is not present
  # @return [String] The preview URL
  def attachment_preview_url(attachment, variant_options: nil, default_url: "/icon.svg")
    return default_url unless attachment&.attached? && attachment.blob.persisted?

    if variant_options
      rails_representation_url(attachment.variant(variant_options))
    else
      url_for(attachment)
    end
  end

  # Logo link URL
  # Returns account's logo_link or root_path as fallback
  def branded_logo_url
    Current.account&.logo_link.presence || root_path
  end

  # Branded logo image
  # Returns account logo or default FeedbackBin mark
  # @param options [Hash] HTML options to pass to the image/svg tag
  def branded_logo(**options)
    if Current.account
      account_logo(Current.account, **options)
    else
      inline_svg_tag("mark.svg", **options)
    end
  end

  # Brand name
  # Returns account name or default brand name
  def brand_name
    Current.account&.name || t("application.navbar.brand_name")
  end

  # Whether to show the brand name
  # Returns true if no account or account wants to show name
  def show_brand_name?
    Current.account.nil? || Current.account.show_company_name?
  end
end
