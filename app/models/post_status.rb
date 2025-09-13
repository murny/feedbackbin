# frozen_string_literal: true

class PostStatus < ApplicationRecord
  has_many :posts, dependent: :nullify

  validates :name, presence: true
  validates :position, presence: true, numericality: { only_integer: true }
  validates :color, presence: true, format: { with: /\A#[0-9a-f]{6}\z/i }
end
