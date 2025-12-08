# frozen_string_literal: true

module Comment::Threadable
  extend ActiveSupport::Concern

  included do
    belongs_to :parent, class_name: "Comment", optional: true
    has_many :replies, class_name: "Comment", foreign_key: :parent_id, dependent: :destroy, inverse_of: :parent

    validate :ensure_single_level_nesting

    scope :top_level, -> { where(parent_id: nil) }
    scope :replies_to, ->(comment) { where(parent_id: comment.id) }
  end

  def top_level?
    parent_id.nil?
  end

  def reply?
    parent_id.present?
  end

  def has_replies?
    replies.any?
  end

  private
    def ensure_single_level_nesting
      if parent_id.present?
        parent_comment = Comment.find_by(id: parent_id)
        if parent_comment&.parent_id.present?
          errors.add(:parent_id, "cannot be nested more than one level")
        end
      end
    end
end
