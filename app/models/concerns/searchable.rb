# frozen_string_literal: true

module Searchable
  SEARCH_CONTENT_LIMIT = 32.kilobytes

  extend ActiveSupport::Concern

  included do
    has_one :search_record, as: :searchable, class_name: "Search::Record", dependent: :destroy

    after_commit :upsert_search_record, on: [ :create, :update ]
    after_commit :remove_search_record, on: :destroy
  end

  def searchable?
    true
  end

  def search_title
    raise NotImplementedError
  end

  def search_content
    raise NotImplementedError
  end

  def search_board_id
    raise NotImplementedError
  end

  def search_idea_id
    raise NotImplementedError
  end

  def search_record_content
    search_content.to_s.truncate(SEARCH_CONTENT_LIMIT)
  end

  def reindex
    if searchable?
      Search::Record.upsert_for(self)
    else
      Search::Record.remove_for(self)
    end
  end

  private

    def upsert_search_record
      reindex
    end

    def remove_search_record
      Search::Record.remove_for(self)
    end
end
