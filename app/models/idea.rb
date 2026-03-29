# frozen_string_literal: true

class Idea < ApplicationRecord
  DEFAULT_STATUS_COLOR = "#3b82f6"

  include ModelSortable
  include Voteable
  include Idea::Searchable
  include Idea::Eventable
  include Idea::Taggable
  include Idea::Watchable
  include Mentioning

  has_rich_text :description
  mentionable_rich_text :description

  to_param :title

  belongs_to :account, default: -> { Current.account }
  belongs_to :creator, class_name: "User", default: -> { Current.user }
  belongs_to :board
  belongs_to :status, optional: true
  belongs_to :official_comment, class_name: "Comment", optional: true

  has_many :comments, dependent: :destroy

  broadcasts_refreshes

  validates :title, presence: true
  validate :official_comment_must_belong_to_idea, if: :official_comment_id?

  scope :ordered_with_pinned, -> { order(pinned: :desc, created_at: :desc) }
  scope :open, -> { where.missing(:status) }
  scope :with_status, -> { where.associated(:status) }

  # Returns the status name, or "Open" if no status assigned
  def status_name
    status&.name || I18n.t("ideas.default_status")
  end

  # Returns the status color, or a default color if no status assigned
  def status_color
    status&.color || DEFAULT_STATUS_COLOR
  end

  def open?
    status.nil?
  end

  def official_response?
    official_comment_id?
  end

  def set_official_response!(comment, actor:)
    raise ArgumentError, "actor must be an admin" unless actor.admin?
    update!(official_comment: comment)
  end

  def clear_official_response!(actor:)
    raise ArgumentError, "actor must be an admin" unless actor.admin?
    update!(official_comment: nil)
  end

  def participant_ids
    @participant_ids ||= begin
      comment_creator_ids = comments.joins(:creator)
                                    .where.not(users: { role: :system })
                                    .order(created_at: :desc)
                                    .pluck(:creator_id)
                                    .uniq

      creator.system? ? comment_creator_ids : ([ creator_id ] + comment_creator_ids).uniq
    end
  end

  def participants(limit: 10)
    ids = participant_ids.first(limit)
    return [] if ids.empty?

    account.users.active.where(id: ids).index_by(&:id).values_at(*ids).compact
  end

  private

    def official_comment_must_belong_to_idea
      return unless official_comment.present?

      errors.add(:official_comment, :must_belong_to_idea) unless official_comment.idea_id == id
    end
end
