# frozen_string_literal: true

class Category < ApplicationRecord
  has_many :posts, dependent: :destroy
  belongs_to :account, default: -> { Current.account }

  validates :name, presence: true
end
