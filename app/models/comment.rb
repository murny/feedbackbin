# frozen_string_literal: true

class Comment < ApplicationRecord
  include Likeable
  belongs_to :creator, class_name: "User"
  belongs_to :post, counter_cache: true, touch: true
  
  # Organization is now implicit via tenant context - no direct association needed

  belongs_to :parent, class_name: "Comment", optional: true
  has_many :replies, class_name: "Comment", foreign_key: :parent_id, dependent: :destroy, inverse_of: :parent

  has_rich_text :body

  validates :body, presence: true

  scope :ordered, -> { order(created_at: :asc) }

  # TODO: Add turbo stream broadcasts?
end
