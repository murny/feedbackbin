# frozen_string_literal: true

class UserIdentity < ApplicationRecord
  belongs_to :user

  validates :provider_name, presence: true
  validates :provider_uid, presence: true, uniqueness: {scope: :provider_name}
  validates :user, uniqueness: {scope: :provider_name}
end
