# frozen_string_literal: true

class Post < ApplicationRecord
  include ModelSortable
  include Likeable
  include Searchable
  include Subscribable

  has_rich_text :body

  belongs_to :author, class_name: "User", default: -> { Current.user }
  belongs_to :category
  belongs_to :post_status, default: -> { PostStatus.default }

  has_many :comments, dependent: :destroy

  broadcasts_refreshes

  validates :title, presence: true

  scope :ordered_with_pinned, -> { order(pinned: :desc, created_at: :desc) }

  after_create :subscribe_author
  after_create :notify_admins_of_new_post

  private

    def subscribe_author
      subscribe(author) if author
    end

    def notify_admins_of_new_post
      return unless author

      NewPostCreatedNotification.with(
        post: self,
        author: author
      ).deliver_later(User.where(role: :administrator).where.not(id: author.id))
    end
end
