# frozen_string_literal: true

class Tag < ApplicationRecord
  include Tag::Attachable

  belongs_to :account, default: -> { Current.account }
  has_many :taggings, dependent: :destroy
  has_many :ideas, through: :taggings

  validates :title, presence: true, uniqueness: { scope: :account_id }, format: { without: /\A#/ }

  normalizes :title, with: -> { _1.strip.downcase }

  scope :alphabetically, -> { order(Arel.sql("lower(title)")) }
  scope :unused, -> { left_outer_joins(:taggings).where(taggings: { id: nil }) }

  def hashtag
    "##{title}"
  end
end
