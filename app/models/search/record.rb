# frozen_string_literal: true

class Search::Record < ApplicationRecord
  self.table_name = "search_records"

  RESULT_LIMIT = 20

  belongs_to :account
  belongs_to :board, optional: true
  belongs_to :idea, optional: true
  belongs_to :searchable, polymorphic: true

  after_save :upsert_fts_record
  after_destroy :remove_fts_record

  def self.search(query, account:, board: nil)
    sanitized = Search::Query.sanitize(query)
    return none if sanitized.blank?

    matching_ids = Search::Record::Fts.matching(sanitized).pluck(:rowid)
    return none if matching_ids.empty?

    scope = where(account: account, id: matching_ids)
    scope = scope.where(board: board) if board.present?
    scope.includes(:idea, :board).order(
      Arel.sql("CASE searchable_type WHEN 'Idea' THEN 0 ELSE 1 END"),
      created_at: :desc
    ).limit(RESULT_LIMIT)
  end

  def self.upsert_for(searchable)
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

  def self.remove_for(searchable)
    find_by(
      searchable_type: searchable.class.name,
      searchable_id: searchable.id
    )&.destroy
  end

  private

    def upsert_fts_record
      Search::Record::Fts.upsert(id, title, content)
    end

    def remove_fts_record
      Search::Record::Fts.remove(id)
    end
end
