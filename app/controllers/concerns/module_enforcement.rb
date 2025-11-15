# frozen_string_literal: true

module ModuleEnforcement
  extend ActiveSupport::Concern

  included do
    before_action :enforce_module_access
  end

  private

    def enforce_module_access
      return if skip_module_enforcement?
      return unless Current.organization

      module_name = current_module_name
      return unless module_name

      unless Current.organization.module_enabled?(module_name)
        raise ActionController::RoutingError, "Module not enabled"
      end
    end

    def skip_module_enforcement?
      # Skip for admin, auth, and other system controllers
      controller_path.start_with?("admin/") ||
        controller_path.start_with?("users/") ||
        controller_name.in?(%w[sessions registrations passwords first_runs invitations static])
    end

    def current_module_name
      # Determine which module this controller belongs to
      case controller_path
      when /^posts/, /^comments/
        :posts
      when /^roadmap/
        :roadmap
      when /^changelogs/
        :changelog
      end
    end
end
