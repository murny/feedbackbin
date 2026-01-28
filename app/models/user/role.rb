# frozen_string_literal: true

module User::Role
  extend ActiveSupport::Concern

  included do
    enum :role, [ :owner, :admin, :member, :system, :bot ].index_by(&:itself), default: :member, validate: true

    scope :admin, -> { where(active: true, role: [ :owner, :admin ]) }
    scope :owner, -> { where(active: true, role: :owner) }
    scope :member, -> { where(active: true, role: :member) }

    validate :account_owner_cannot_change_role, if: -> { role_changed? && role_was == "owner" }

    def admin?
      super || owner?
    end

    private

      def account_owner_cannot_change_role
        errors.add(:role, :account_owner_cannot_change)
      end
  end

  def can_change?(other)
    (admin? && !other.owner?) || other == self
  end

  def can_administer?(other)
    admin? && !other.owner? && other != self
  end

  def can_administer_idea?(idea)
    admin? || idea.creator == self
  end

  def can_administer_comment?(comment)
    admin? || comment.creator == self
  end
end
