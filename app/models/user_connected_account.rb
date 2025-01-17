# frozen_string_literal: true

class UserConnectedAccount < ApplicationRecord
  belongs_to :user

  validates :provider_name, presence: true
  validates :provider_uid, presence: true, uniqueness: { scope: :provider_name }
  validates :user, uniqueness: { scope: :provider_name }
end
