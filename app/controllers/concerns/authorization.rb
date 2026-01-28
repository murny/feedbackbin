# frozen_string_literal: true

module Authorization
  extend ActiveSupport::Concern

  private

    def ensure_admin
      head :forbidden unless Current.user&.admin?
    end

    def ensure_owner
      head :forbidden unless Current.user&.owner?
    end
end
