# frozen_string_literal: true

class Changelog
  module Searchable
    extend ActiveSupport::Concern
    include ::Searchable

    def search_title = title
    def search_content = description.to_plain_text
    def search_board_id = nil
    def search_idea_id = nil

    def searchable?
      published?
    end
  end
end
