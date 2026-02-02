# frozen_string_literal: true

class Comment < ApplicationRecord
  include Voteable
  include Comment::Eventable

  belongs_to :account, default: -> { Current.account }
  belongs_to :creator, class_name: "User", default: -> { Current.user }
  belongs_to :idea, counter_cache: true, touch: true

  belongs_to :parent, class_name: "Comment", optional: true
  has_many :replies, class_name: "Comment", foreign_key: :parent_id, dependent: :destroy, inverse_of: :parent

  has_rich_text :body

  validates :body, presence: true
  validate :parent_must_be_top_level_comment, if: :parent_id?

  after_create_commit :watch_idea_by_creator

  scope :ordered, -> { order(created_at: :asc) }
  scope :by_oldest, -> { order(created_at: :asc) }
  scope :by_newest, -> { order(created_at: :desc) }
  scope :by_top, -> { order(votes_count: :desc, created_at: :asc) }

  def self.sorted_by(sort_option)
    case sort_option&.to_sym
    when :newest then by_newest
    when :top then by_top
    else by_oldest
    end
  end

  private

    def parent_must_be_top_level_comment
      return unless parent.present?

      if parent.idea_id != idea_id
        errors.add(:parent_id, :must_belong_to_same_idea)
      elsif parent.parent_id.present?
        errors.add(:parent_id, :cannot_reply_to_reply)
      end
    end

    def watch_idea_by_creator
      idea.watch_by(creator)
    end
end
