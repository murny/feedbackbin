# frozen_string_literal: true

class Post < ApplicationRecord
  include ModelSortable
  include Likeable

  has_rich_text :body

  belongs_to :author, class_name: "User", default: -> { Current.user }
  belongs_to :category
  belongs_to :post_status, optional: true

  has_many :top_comments, -> { where(parent_id: nil) }, class_name: "Comment"

  has_many :comments, dependent: :destroy

  broadcasts_refreshes

  validates :title, presence: true
end
