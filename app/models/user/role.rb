# frozen_string_literal: true

module User::Role
  extend ActiveSupport::Concern

  included do
    enum :role, { member: 0, admin: 1, bot: 2 }, default: :member, validate: true

    validate :organization_owner_cannot_change_role, if: -> { role_changed? && organization_owner? }

    private

      def organization_owner_cannot_change_role
        errors.add(:role, :organization_owner_cannot_change)
      end
  end
end
