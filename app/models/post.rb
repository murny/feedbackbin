# frozen_string_literal: true

class Post < ApplicationRecord
  include ModelSortable
  include Likeable
  include Searchable
  include Eventable
  include Broadcastable
  include Post::Pinnable
  include Post::Statusable

  has_rich_text :body

  to_param :title

  belongs_to :author, class_name: "User", default: -> { Current.user }
  belongs_to :category

  has_many :comments, dependent: :destroy

  validates :title, presence: true

  # Track events for post lifecycle
  after_create_commit -> { track_event(:created, creator: author) }
  after_update_commit -> { track_event(:updated, creator: author) }, if: -> { saved_change_to_title? }
  before_destroy -> { track_event(:deleted, creator: Current.user || Current.organization&.system_user) }
end
