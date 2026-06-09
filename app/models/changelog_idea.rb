# frozen_string_literal: true

class ChangelogIdea < ApplicationRecord
  belongs_to :account, default: -> { Current.account }
  belongs_to :changelog
  belongs_to :idea

  attr_readonly :changelog_id, :idea_id

  validates :idea_id, uniqueness: { scope: :changelog_id }
end
