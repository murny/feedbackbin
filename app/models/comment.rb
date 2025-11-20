# frozen_string_literal: true

class Comment < ApplicationRecord
  include Likeable

  belongs_to :creator, class_name: "User", default: -> { Current.user }
  belongs_to :post, touch: true

  belongs_to :parent, class_name: "Comment", optional: true
  has_many :replies, class_name: "Comment", foreign_key: :parent_id, dependent: :destroy, inverse_of: :parent

  has_rich_text :body

  validates :body, presence: true

  scope :ordered, -> { order(created_at: :asc) }

  def likes_count
    Rails.cache.fetch("#{cache_key_with_version}/likes_count", expires_in: 1.minute) do
      likes.count
    end
  end

  # TODO: Validation for parent_id parent is a Post (no more than 1 level of nesting of comments)
  #
  # TODO: Add turbo stream broadcasts?
end
