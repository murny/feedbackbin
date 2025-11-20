# frozen_string_literal: true

class Post < ApplicationRecord
  include ModelSortable
  include Likeable
  include Searchable

  has_rich_text :body

  to_param :title

  belongs_to :author, class_name: "User", default: -> { Current.user }
  belongs_to :category
  belongs_to :post_status, default: -> { PostStatus.default }

  has_many :comments, dependent: :destroy

  broadcasts_refreshes

  validates :title, presence: true

  scope :ordered_with_pinned, -> { order(pinned: :desc, created_at: :desc) }

  def comments_count
    Rails.cache.fetch("#{cache_key_with_version}/comments_count", expires_in: 5.minutes) do
      comments.count
    end
  end

  def likes_count
    Rails.cache.fetch("#{cache_key_with_version}/likes_count", expires_in: 1.minute) do
      likes.count
    end
  end
end
