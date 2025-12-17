# frozen_string_literal: true

class Status < ApplicationRecord
  belongs_to :account, default: -> { Current.account }
  has_many :ideas, dependent: :nullify

  validates :name, presence: true
  validates :position, presence: true, numericality: { only_integer: true }
  validates :color, presence: true, format: { with: /\A#[0-9a-f]{6}\z/i }

  # Visibility flag validations
  validates :show_on_idea, inclusion: { in: [ true, false ] }
  validates :show_on_roadmap, inclusion: { in: [ true, false ] }

  scope :ordered, -> { order(:position) }

  # Visibility scopes
  scope :visible_on_idea, -> { where(show_on_idea: true) }
  scope :visible_on_roadmap, -> { where(show_on_roadmap: true) }
end
