# frozen_string_literal: true

class Reaction < ApplicationRecord
  belongs_to :account, default: -> { reactable.account }
  belongs_to :reactable, polymorphic: true, touch: true
  belongs_to :reacter, class_name: "User", default: -> { Current.user }

  scope :ordered, -> { order(:created_at) }
  scope :grouped_with_counts, -> {
    group(:content).order("COUNT(*) DESC").count
  }

  validates :content, presence: true, length: { maximum: 16 }
  validates :reacter_id, uniqueness: {
    scope: [ :reactable_type, :reactable_id, :content ],
    message: :already_reacted
  }
end
