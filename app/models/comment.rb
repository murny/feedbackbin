# frozen_string_literal: true

class Comment < ApplicationRecord
  include ActionView::RecordIdentifier
  include Likeable

  belongs_to :creator, class_name: "User", default: -> { Current.user }

  belongs_to :commentable, polymorphic: true, counter_cache: true
  belongs_to :parent, optional: true, class_name: "Comment"
  has_many :comments, foreign_key: :parent_id, inverse_of: :parent, dependent: :destroy

  has_rich_text :body

  validates :body, presence: true

  scope :ordered, -> { order(created_at: :desc) }

  after_create_commit do
    broadcast_prepend_to [commentable, :comments], target: "#{dom_id(parent || commentable)}_comments", partial: "comments/comment_with_replies"
  end

  after_update_commit do
    broadcast_replace_to self
  end

  after_destroy_commit do
    broadcast_remove_to self
    broadcast_action_to self, action: :remove, target: "#{dom_id(self)}_with_comments"
  end
end
