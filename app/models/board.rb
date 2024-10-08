# frozen_string_literal: true

class Board < ApplicationRecord
  has_many :posts, dependent: :destroy

  validates :name, presence: true
end
