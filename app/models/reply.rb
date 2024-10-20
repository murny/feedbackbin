# frozen_string_literal: true

class Reply < ApplicationRecord
  belongs_to :creator, class_name: "User", default: -> { Current.user }
  belongs_to :comment, counter_cache: true, touch: true

  has_rich_text :body

  validates :body, presence: true

  scope :ordered, -> { order(created_at: :desc) }

  # after_create_commit do
  #   broadcast_prepend_to [comment, :replies], target: "comment_#{comment.id}_replies", partial: "replies/reply"
  # end

  # after_update_commit do
  #   broadcast_replace_to self
  # end

  # after_destroy_commit do
  #   broadcast_remove_to self
  # end
end
