# frozen_string_literal: true

module User::Role
  extend ActiveSupport::Concern

  included do
    enum :role, [ :owner, :admin, :member, :system, :bot ].index_by(&:itself), default: :member, validate: true

    validate :account_owner_cannot_change_role, if: -> { role_changed? && role_was == "owner" }

    private

      def account_owner_cannot_change_role
        errors.add(:role, :account_owner_cannot_change)
      end
  end
end
