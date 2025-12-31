# frozen_string_literal: true

class Idea < ApplicationRecord
  DEFAULT_STATUS_COLOR = "#3b82f6"

  include ModelSortable
  include Voteable
  include Searchable
  include Eventable

  has_rich_text :description

  to_param :title

  belongs_to :account, default: -> { Current.account }
  belongs_to :creator, class_name: "User", default: -> { Current.user }
  belongs_to :board
  belongs_to :status, optional: true

  has_many :comments, dependent: :destroy

  broadcasts_refreshes

  validates :title, presence: true

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

  # Called by Event after creation (via Eventable concern)
  # Creates system comments for visible audit trail
  def event_was_created(event)
    create_system_comment_for(event)
  end

  # Event tracking callbacks
  after_create_commit :track_creation
  after_update :track_status_change, if: :saved_change_to_status_id?
  after_update :track_board_change, if: :saved_change_to_board_id?
  after_update :track_title_change, if: :saved_change_to_title?

  private

  def track_creation
    track_event(:created)
  end

  def track_status_change
    old_status = status_id_before_last_save.present? ? Status.find(status_id_before_last_save).name : "Open"
    new_status = status_name
    track_event(:status_changed, particulars: { old_status: old_status, new_status: new_status })
  end

  def track_board_change
    old_board = Board.find(board_id_before_last_save).name
    new_board = board.name
    track_event(:board_changed, particulars: { old_board: old_board, new_board: new_board })
  end

  def track_title_change
    track_event(:title_changed, particulars: { old_title: title_before_last_save, new_title: title })
  end

  def create_system_comment_for(event)
    Idea::SystemCommenter.new(self, event).comment
  end
end
