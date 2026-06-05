# frozen_string_literal: true

class Search::Record < ApplicationRecord
  self.table_name = "search_records"

  RESULT_LIMIT = 20

  OPENING_MARK = "<mark>"
  CLOSING_MARK = "</mark>"
  SNIPPET_ELLIPSIS = "..."

  attribute :result_title, :string
  attribute :result_content, :string

  belongs_to :account
  belongs_to :board, optional: true
  belongs_to :idea, optional: true
  belongs_to :searchable, polymorphic: true

  after_save :upsert_fts_record
  after_destroy :remove_fts_record

  class << self
    def search(query, account:, board: nil)
      query = Search::Query.wrap(query)
      return none if query.blank?

      scope = matching(query.to_s)
        .where(account: account)
        .includes(:idea, :board, :searchable)
        .select("search_records.*", *search_fields(query))
        .order(Arel.sql("bm25(search_records_fts) ASC"))
        .limit(RESULT_LIMIT)
      scope = scope.where(board: board) if board.present?
      scope.to_a
    end

    def matching(query)
      joins("INNER JOIN search_records_fts ON search_records_fts.rowid = search_records.id")
        .where("search_records_fts MATCH ?", query)
    end

    def upsert_for(searchable)
      record = find_or_initialize_by(
        searchable_type: searchable.class.name,
        searchable_id: searchable.id
      )
      record.assign_attributes(
        account_id: searchable.account_id,
        board_id: searchable.search_board_id,
        idea_id: searchable.search_idea_id,
        title: searchable.search_title,
        content: searchable.search_record_content
      )
      record.save!
      record
    end

    def remove_for(searchable)
      find_by(
        searchable_type: searchable.class.name,
        searchable_id: searchable.id
      )&.destroy
    end

    private

      def search_fields(query)
        opening = connection.quote(OPENING_MARK)
        closing = connection.quote(CLOSING_MARK)
        ellipsis = connection.quote(SNIPPET_ELLIPSIS)

        [
          Arel.sql("highlight(search_records_fts, 0, #{opening}, #{closing}) AS result_title"),
          Arel.sql("snippet(search_records_fts, 1, #{opening}, #{closing}, #{ellipsis}, 40) AS result_content")
        ]
      end
  end

  def display_title
    escape_fts_highlight(result_title) || title
  end

  def display_snippet
    escape_fts_highlight(result_content) || content&.truncate(150)
  end

  def display_url
    case searchable_type
    when "Idea"
      Rails.application.routes.url_helpers.idea_path(idea, script_name: Current.account&.slug)
    when "Comment"
      Rails.application.routes.url_helpers.idea_path(idea, anchor: "comment_#{searchable.id}", script_name: Current.account&.slug)
    when "Changelog"
      Rails.application.routes.url_helpers.changelog_path(searchable, script_name: Current.account&.slug)
    end
  end

  def type_key
    case searchable_type
    when "Idea" then "idea"
    when "Comment" then "comment"
    when "Changelog" then "changelog"
    end
  end

  def idea?      = searchable_type == "Idea"
  def comment?   = searchable_type == "Comment"
  def changelog? = searchable_type == "Changelog"

  private

    def escape_fts_highlight(html)
      return nil if html.blank?

      CGI.escapeHTML(html)
        .gsub(CGI.escapeHTML(OPENING_MARK), OPENING_MARK)
        .gsub(CGI.escapeHTML(CLOSING_MARK), CLOSING_MARK)
        .html_safe
    end

    def upsert_fts_record
      Search::Record::Fts.upsert(id, title, content)
    end

    def remove_fts_record
      Search::Record::Fts.remove(id)
    end
end
