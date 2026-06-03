# frozen_string_literal: true

class Comment < ApplicationRecord
  include Voteable
  include Comment::Searchable
  include Comment::Eventable
  include Mentioning

  belongs_to :account, default: -> { Current.account }
  belongs_to :creator, class_name: "User", default: -> { Current.user }
  belongs_to :idea, touch: true

  belongs_to :parent, class_name: "Comment", optional: true
  has_many :replies, class_name: "Comment", foreign_key: :parent_id, dependent: :destroy, inverse_of: :parent
  has_many :reactions, as: :reactable, dependent: :delete_all

  has_rich_text :body
  mentionable_rich_text :body

  attr_readonly :parent_id

  validates :body, presence: true
  validate :parent_must_be_top_level_comment, if: :parent_id?
  validate :reply_to_internal_only_by_staff, if: :parent_id?

  after_create :increment_idea_comments_count
  after_create_commit :watch_idea_by_creator
  before_update :stamp_edited_at_if_body_text_changed
  before_destroy :clear_official_response_references
  after_destroy :decrement_idea_comments_count

  scope :ordered, -> { order(created_at: :asc) }
  scope :top_level, -> { where(parent_id: nil) }
  scope :by_oldest, -> { order(created_at: :asc) }
  scope :by_newest, -> { order(created_at: :desc) }
  scope :by_top, -> { order(votes_count: :desc, created_at: :asc) }
  scope :public_only, -> { where(internal: false) }
  scope :internal_only, -> { where(internal: true) }

  def self.sorted_by(sort_option)
    case sort_option&.to_sym
    when :newest then by_newest
    when :top then by_top
    else by_oldest
    end
  end

  def self.visible_to(user)
    user&.admin? ? all : public_only
  end

  def edited?
    edited_at.present?
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

    def reply_to_internal_only_by_staff
      return unless parent&.internal? && !creator&.admin?

      errors.add(:parent_id, :cannot_reply_to_internal)
    end

    def watch_idea_by_creator
      idea.watch_by(creator)
    end

    def increment_idea_comments_count
      return if internal?

      idea.increment!(:comments_count)
    end

    def decrement_idea_comments_count
      return if internal?
      return if destroyed_by_association&.foreign_key == "idea_id"

      idea.decrement!(:comments_count)
    end

    def clear_official_response_references
      Idea.where(official_comment_id: id).update_all(official_comment_id: nil)
    end

    def stamp_edited_at_if_body_text_changed
      return unless body&.body_changed?
      return if body.body_was&.to_plain_text.to_s == body.body.to_plain_text.to_s

      self.edited_at = Time.current
    end
end
