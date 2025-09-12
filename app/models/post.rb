# frozen_string_literal: true

class Post < ApplicationRecord
  include ModelSortable
  include Likeable
  include Searchable
  include CrossTenantAssociations

  has_rich_text :body

  belongs_to_shared :author, class_name: "User", required: true
  belongs_to :category
  belongs_to :post_status, optional: true
  
  # Organization is now implicit via tenant context - no direct association needed

  has_many :comments, dependent: :destroy

  broadcasts_refreshes

  validates :title, presence: true

  scope :ordered_with_pinned, -> { order(pinned: :desc, created_at: :desc) }
end
