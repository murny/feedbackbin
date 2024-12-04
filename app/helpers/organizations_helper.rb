module OrganizationsHelper
  def organization_logo(organization)
    if organization.logo.attached?
      image_tag organization.logo, class: "rounded size-8", alt: organization.name
    else
      tag.div organization.name[0..1], class: "size-8 uppercase rounded bg-gray-600 text-white text-xs flex items-center justify-center"
    end
  end
end
