# frozen_string_literal: true

class Status < ApplicationRecord
  belongs_to :account, default: -> { Current.account }
  has_many :ideas, dependent: :restrict_with_error

  validates :name, presence: true
  validates :position, presence: true, numericality: { only_integer: true }
  validates :color, presence: true, format: { with: /\A#[0-9a-f]{6}\z/i }

  # Visibility flag validations
  validates :show_on_idea, inclusion: { in: [ true, false ] }
  validates :show_on_roadmap, inclusion: { in: [ true, false ] }

  scope :ordered, -> { order(:position) }

  def self.default
    Current.account&.default_status
  end

  # Visibility scopes
  scope :visible_on_idea, -> { where(show_on_idea: true) }
  scope :visible_on_roadmap, -> { where(show_on_roadmap: true) }

  before_destroy :prevent_default_deletion

  private

    def prevent_default_deletion
      if account&.default_status_id == id
        errors.add(:base, :cannot_delete_default)
        throw(:abort)
      end
    end
end
