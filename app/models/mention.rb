# frozen_string_literal: true

class Mention < ApplicationRecord
  include Notifiable

  belongs_to :account, default: -> { source.account }
  belongs_to :source, polymorphic: true
  belongs_to :mentioner, class_name: "User"
  belongs_to :mentionee, class_name: "User", inverse_of: :mentions

  after_create_commit :watch_idea_by_mentionee

  def self_mention?
    mentioner == mentionee
  end

  def idea
    case source
    when Idea then source
    when Comment then source.idea
    end
  end

  private

    def watch_idea_by_mentionee
      idea&.watch_by(mentionee)
    end
end
