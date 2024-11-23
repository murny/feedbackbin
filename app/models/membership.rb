# frozen_string_literal: true

class Membership < ApplicationRecord
  include Role

  belongs_to :organization, counter_cache: true
  belongs_to :user

  validates :user, uniqueness: {scope: :organization_id}
  validate :owner_must_be_administrator, on: :update, if: -> { role_changed? && organization_owner? }

  def organization_owner?
    organization.owner_id == user_id
  end

  private

  def owner_must_be_administrator
    errors.add :role, :administrator_cannot_be_removed unless administrator?
  end
end
