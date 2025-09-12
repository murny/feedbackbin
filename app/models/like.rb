# frozen_string_literal: true

class Like < ApplicationRecord
  belongs_to :voter, class_name: "User"
  belongs_to :likeable, polymorphic: true, counter_cache: true, touch: true
  
  # Organization is now implicit via tenant context - no direct association needed

  validates :voter_id, uniqueness: { scope: %i[likeable_type likeable_id] }
end
