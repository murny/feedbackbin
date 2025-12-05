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

  # Scopes for sorting by aggregated counts (used when sorting, not for display)
  scope :with_comments_count_for_sorting, -> {
    left_joins(:comments)
      .group("posts.id")
      .select("posts.*, COUNT(DISTINCT comments.id) as comments_count_sql")
  }

  scope :with_likes_count_for_sorting, -> {
    left_joins(:likes)
      .group("posts.id")
      .select("posts.*, COUNT(DISTINCT likes.id) as likes_count_sql")
  }

  # Override sortable_columns to include count-based columns
  def self.sortable_columns
    super + [ "comments_count", "likes_count" ]
  end

  # Override sort_by_params to handle count-based sorting
  def self.sort_by_params(column, direction)
    return with_comments_count_for_sorting.order("comments_count_sql" => direction) if column == "comments_count"
    return with_likes_count_for_sorting.order("likes_count_sql" => direction) if column == "likes_count"

    super
  end

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
