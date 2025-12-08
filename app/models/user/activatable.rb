# frozen_string_literal: true

module User::Activatable
  extend ActiveSupport::Concern

  included do
    scope :active, -> { where(active: true) }
    scope :deactivated, -> { where(active: false) }

    validate :organization_owner_cannot_be_deactivated, if: -> { active_changed? && organization_owner? }
  end

  def deactivate
    success = transaction do
      if update(active: false)
        sessions.delete_all
        true
      else
        raise ActiveRecord::Rollback
      end
    end

    return false unless success

    close_remote_connections
    true
  end

  def deactivated?
    !active?
  end

  private
    def close_remote_connections
      ActionCable.server.remote_connections.where(current_user: self).disconnect reconnect: false
    end

    def organization_owner_cannot_be_deactivated
      errors.add(:active, :organization_owner_cannot_be_deactivated)
    end
end
