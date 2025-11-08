# frozen_string_literal: true

class Comment < ApplicationRecord
  include Likeable

  belongs_to :creator, class_name: "User", default: -> { Current.user }
  belongs_to :post, counter_cache: true, touch: true

  belongs_to :parent, class_name: "Comment", optional: true
  has_many :replies, class_name: "Comment", foreign_key: :parent_id, dependent: :destroy, inverse_of: :parent

  has_rich_text :body

  validates :body, presence: true

  scope :ordered, -> { order(created_at: :asc) }

  after_create :subscribe_creator_to_post
  after_create :notify_subscribers_of_new_comment
  after_create :notify_parent_comment_creator

  # TODO: Validation for parent_id parent is a Post (no more than 1 level of nesting of comments)
  #
  # TODO: Add turbo stream broadcasts?

  private

    def subscribe_creator_to_post
      post.subscribe(creator) if creator && post
    end

    def notify_subscribers_of_new_comment
      return unless post && creator

      PostCommentedNotification.with(
        post: post,
        comment: self,
        commenter: creator
      ).deliver_later(post.active_subscribers)
    end

    def notify_parent_comment_creator
      return unless parent && creator

      CommentRepliedNotification.with(
        comment: self,
        parent_comment: parent,
        replier: creator,
        post: post
      ).deliver_later([ parent.creator ])
    end
end
