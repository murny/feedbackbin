# frozen_string_literal: true

class IdentityConnectedAccount < ApplicationRecord
  belongs_to :identity

  validates :provider_name, presence: true
  validates :provider_uid, presence: true, uniqueness: { scope: :provider_name }
  validates :identity, uniqueness: { scope: :provider_name }
end
