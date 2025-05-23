# frozen_string_literal: true

class Like < ApplicationRecord
  belongs_to :voter, class_name: "User", default: -> { Current.user }
  belongs_to :likeable, polymorphic: true, counter_cache: true, touch: true
  belongs_to :organization, default: -> { likeable.organization }

  validates :voter_id, uniqueness: { scope: %i[likeable_type likeable_id] }
end
