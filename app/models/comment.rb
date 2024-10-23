# frozen_string_literal: true

class Comment < ApplicationRecord
  include Likeable

  belongs_to :creator, class_name: "User", default: -> { Current.user }
  belongs_to :post, counter_cache: true, touch: true

  has_many :replies, dependent: :destroy

  has_rich_text :body

  validates :body, presence: true

  scope :ordered, -> { order(created_at: :desc) }

  after_create_commit do
    broadcast_prepend_to [post, :comments], target: "post_#{post.id}_comments", partial: "comments/comment_with_replies"
  end

  after_update_commit do
    broadcast_replace_to self
  end

  after_destroy_commit do
    broadcast_remove_to self
    broadcast_action_to self, action: :remove, target: "comment_#{id}_with_comments"
  end
end
