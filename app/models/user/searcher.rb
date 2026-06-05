# frozen_string_literal: true

class User
  module Searcher
    extend ActiveSupport::Concern

    def search(query, board: nil)
      Search::Record.search(query, account: account, board: board)
    end
  end
end
