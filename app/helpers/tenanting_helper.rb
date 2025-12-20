# frozen_string_literal: true

module TenantingHelper
  # Generates ActionCable meta tag with account-scoped URL path
  # Use this instead of action_cable_meta_tag in layouts
  def tenanted_action_cable_meta_tag
    tag.meta(
      name: "action-cable-url",
      content: "#{request.script_name}#{ActionCable.server.config.mount_path}"
    )
  end
end
