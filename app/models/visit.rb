# frozen_string_literal: true

class Visit < ApplicationRecord
  belongs_to :account, default: -> { Current.account }
  belongs_to :user
  belongs_to :idea, touch: false

  scope :recent, -> { order(visited_at: :desc) }

  def self.record(idea:, user:)
    return unless user.present?

    Visit.upsert(
      {
        account_id: Current.account.id,
        user_id: user.id,
        idea_id: idea.id,
        visited_at: Time.current
      },
      unique_by: :idx_visits_uniqueness,
      update_only: [ :visited_at ]
    )
  end
end
