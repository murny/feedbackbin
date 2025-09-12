# frozen_string_literal: true

class Category < ApplicationRecord
  has_many :posts, dependent: :destroy
  
  # Organization is now implicit via tenant context - no direct association needed
  validates :name, presence: true, uniqueness: { case_sensitive: false }

  normalizes :name, with: ->(name) { name.squish }
end
