# frozen_string_literal: true

class Visit < ApplicationRecord
  belongs_to :account, default: -> { Current.account }
  belongs_to :user
  belongs_to :idea, touch: false

  scope :recent, -> { order(visited_at: :desc) }

  def self.record(idea:, user:)
    return unless user.present?

    visit = find_or_initialize_by(account: Current.account, user: user, idea: idea)
    visit.visited_at = Time.current
    visit.save!
    visit
  end
end
