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
  has_many :changelog_ideas, dependent: :destroy
  has_many :mentioned_in_changelogs, -> { published.order(published_at: :desc) },
           through: :changelog_ideas, source: :changelog

  broadcasts_refreshes

  validates :title, presence: true
  validate :official_comment_must_belong_to_idea, if: :official_comment_id?

  scope :ordered_with_pinned, -> { order(pinned: :desc, created_at: :desc) }
  scope :open, -> { where.missing(:status) }
  scope :with_status, -> { where.associated(:status) }
  scope :visible_on_idea_page, -> {
    left_outer_joins(:status).where(statuses: { show_on_idea: true })
      .or(left_outer_joins(:status).where(status_id: nil))
  }

  def self.similar_to(title, account: Current.account, limit: 3, exclude: nil)
    return none if title.blank? || title.strip.length < 3

    query = Search::Query.wrap(title)
    return none if query.blank?

    prefixed = query.to_s.split(/\s+/).reject(&:blank?).map { |t| "#{t}*" }.join(" ")
    return none if prefixed.blank?

    fts_rows = Search::Record::Fts.matching_ranked(prefixed).pluck(:rowid, "rank")
    return none if fts_rows.empty?

    ranked_record_ids = fts_rows.map(&:first)

    record_id_to_idea_id = Search::Record
      .where(account: account, id: ranked_record_ids, searchable_type: "Idea")
      .pluck(:id, :searchable_id)
      .to_h

    ordered_idea_ids = ranked_record_ids.map { |rid| record_id_to_idea_id[rid] }.compact
    ordered_idea_ids -= [ exclude.to_i ] unless exclude.nil?
    return none if ordered_idea_ids.empty?

    visible_on_idea_page.where(id: ordered_idea_ids).sort_by { |i| ordered_idea_ids.index(i.id) }.first(limit)
  end

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
