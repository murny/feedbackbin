# frozen_string_literal: true

module OrganizationsHelper
  def organization_logo(organization, size: :default, **options)
    render_avatar(
      src: organization.logo.attached? ? url_for(organization.logo) : nil,
      alt: organization.name,
      size: size,
      fallback: organization.name[0, 2].upcase,
      shape: :square,
      **options
    )
  end
end
