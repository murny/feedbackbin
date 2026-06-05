# frozen_string_literal: true

class Idea
  module Searchable
    extend ActiveSupport::Concern
    include ::Searchable

    class_methods do
      def search(query)
        query = Search::Query.wrap(query)
        return all if query.blank?

        matching_ids = Search::Record::Fts.matching(query.to_s).pluck(:rowid)
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
