# frozen_string_literal: true

# Dynamically choose layout based on tenant context for auth pages.
# Non-tenant (global): Minimal auth layout with FeedbackBin branding
# Tenant (scoped): Full application layout with navbar/footer and org branding
module AuthLayout
  extend ActiveSupport::Concern

  included do
    layout :auth_layout
  end

  private

    def auth_layout
      Current.account.present? ? "application" : "auth"
    end
end
