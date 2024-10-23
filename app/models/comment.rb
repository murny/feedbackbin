# frozen_string_literal: true

class Comment < ApplicationRecord
  include Likeable

  belongs_to :creator, class_name: "User", default: -> { Current.user }
  belongs_to :post, counter_cache: true, touch: true

  belongs_to :parent, class_name: "Comment", optional: true
  has_many :replies, class_name: "Comment", foreign_key: :parent_id, dependent: :destroy, inverse_of: :parent

  has_rich_text :body

  validates :body, presence: true

  scope :ordered, -> { order(created_at: :desc) }

  # TODO: Add turbo stream broadcasts?
end
