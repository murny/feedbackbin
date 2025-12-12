# frozen_string_literal: true

class Idea < ApplicationRecord
  include ModelSortable
  include Voteable
  include Searchable

  has_rich_text :body

  to_param :title

  belongs_to :author, class_name: "User", default: -> { Current.user }
  belongs_to :board
  belongs_to :status, default: -> { Status.default }

  has_many :comments, dependent: :destroy

  broadcasts_refreshes

  validates :title, presence: true

  scope :ordered_with_pinned, -> { order(pinned: :desc, created_at: :desc) }
end
