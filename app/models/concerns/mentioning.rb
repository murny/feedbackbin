# frozen_string_literal: true

# Mentioning concern enables automatic mention extraction and creation for models with rich text.
# Include this in models that have rich text content where users can be mentioned.
#
# Requirements:
# - The model must have a rich text attribute
# - The model must respond to :account and :creator
#
# Example:
#   class Comment < ApplicationRecord
#     include Mentioning
#     has_rich_text :body
#     mentionable_rich_text :body
#   end
module Mentioning
  extend ActiveSupport::Concern

  included do
    has_many :mentions, as: :source, dependent: :destroy
  end

  class_methods do
    def mentionable_rich_text(attribute)
      after_save -> { sync_mentions_for(attribute) }
    end
  end

  private

    def sync_mentions_for(attribute)
      rich_text = public_send(attribute)
      body = rich_text&.body

      mentioned_user_ids = extract_mentioned_user_ids(body)
      current_mentionee_ids = mentions.pluck(:mentionee_id)

      new_mentionee_ids = mentioned_user_ids - current_mentionee_ids
      new_mentionee_ids.each do |mentionee_id|
        mentions.create!(
          mentioner: creator,
          mentionee_id: mentionee_id
        )
      end

      removed_mentionee_ids = current_mentionee_ids - mentioned_user_ids
      mentions.where(mentionee_id: removed_mentionee_ids).destroy_all
    end

    def extract_mentioned_user_ids(action_text_body)
      return [] unless action_text_body.present?

      action_text_body.attachments.filter_map do |attachment|
        attachment.attachable.id if attachment.attachable.is_a?(User)
      end.uniq
    end
end
