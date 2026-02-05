# frozen_string_literal: true

class Tagging < ApplicationRecord
  belongs_to :account, default: -> { idea.account }
  belongs_to :tag
  belongs_to :idea, touch: true

  validates :tag_id, uniqueness: { scope: :idea_id }
end
