# frozen_string_literal: true

class Post < ApplicationRecord
  include ModelSortable
  include Likeable

  has_rich_text :body

  belongs_to :author, class_name: "User", default: -> { Current.user }
  belongs_to :category
  belongs_to :post_status, optional: true
  belongs_to :organization, default: -> { Current.organization }

  has_many :comments, dependent: :destroy

  broadcasts_refreshes unless ENV['DISABLE_TURBO_BROADCASTING'] == 'true'

  validates :title, presence: true

  scope :ordered_with_pinned, -> { order(pinned: :desc, created_at: :desc) }
end
