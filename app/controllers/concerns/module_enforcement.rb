# frozen_string_literal: true

module ModuleEnforcement
  extend ActiveSupport::Concern

  class_methods do
    def enforce_module(module_name)
      before_action do
        if Current.organization && !Current.organization.module_enabled?(module_name)
          raise ActionController::RoutingError, "Module not enabled"
        end
      end
    end
  end
end
