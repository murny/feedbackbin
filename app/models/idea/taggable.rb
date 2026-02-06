# frozen_string_literal: true

module Idea::Taggable
  extend ActiveSupport::Concern

  included do
    has_many :taggings, dependent: :destroy
    has_many :tags, through: :taggings

    scope :tagged_with, ->(tags) { joins(:taggings).where(taggings: { tag: tags }).distinct }
  end

  def toggle_tag_with(title)
    tag = account.tags.find_or_create_by!(title: title)

    transaction do
      if tagged_with?(tag)
        taggings.destroy_by tag: tag
      else
        taggings.create! tag: tag
      end
    end
  end

  def tagged_with?(tag)
    tags.loaded? ? tags.include?(tag) : tags.exists?(tag.id)
  end
end
