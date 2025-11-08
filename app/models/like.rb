# frozen_string_literal: true

class Like < ApplicationRecord
  belongs_to :voter, class_name: "User", default: -> { Current.user }
  belongs_to :likeable, polymorphic: true, counter_cache: true, touch: true

  validates :voter_id, uniqueness: { scope: %i[likeable_type likeable_id] }

  after_create :subscribe_voter_to_post

  private

    def subscribe_voter_to_post
      return unless likeable.is_a?(Post)

      likeable.subscribe(voter) if voter
    end
end
