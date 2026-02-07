# frozen_string_literal: true

class Comment
  module Searchable
    extend ActiveSupport::Concern
    include ::Searchable

    def search_title = idea.title
    def search_content = body.to_plain_text
    def search_board_id = idea.board_id
    def search_idea_id = idea_id
  end
end
