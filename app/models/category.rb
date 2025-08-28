# frozen_string_literal: true

class Category < ApplicationRecord
  has_many :posts, dependent: :destroy
  belongs_to :organization, default: -> { Current.organization }

  validates :name, presence: true, uniqueness: { scope: :organization_id }
end
