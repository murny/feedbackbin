# frozen_string_literal: true

class Idea
  module Searchable
    extend ActiveSupport::Concern
    include ::Searchable

    class_methods do
      def search(query)
        return all if query.blank?

        sanitized = Search::Query.sanitize(query)
        return all if sanitized.blank?

        matching_ids = Search::Record::Fts.matching(sanitized).pluck(:rowid)
        return none if matching_ids.empty?

        idea_ids = Search::Record.where(id: matching_ids, searchable_type: "Idea").pluck(:searchable_id)
        where(id: idea_ids)
      end
    end

    def search_title = title
    def search_content = description.to_plain_text
    def search_board_id = board_id
    def search_idea_id = id
  end
end
