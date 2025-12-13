# frozen_string_literal: true

module AccountsHelper
  def account_logo(account, size: :default, **options)
    return inline_svg_tag("mark.svg", class: options[:class] || "h-8 w-8") if account.nil?

    render Elements::AvatarComponent.new(
      src: account.logo.attached? ? url_for(account.logo) : nil,
      alt: account.name,
      size: size,
      fallback: account.name[0, 2].upcase,
      shape: :square,
      **options
    )
  end
end
