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
    sanitized = sanitize_query(query)
    return none if sanitized.blank?

    fts_rows = Search::Record::Fts.matching_ranked(sanitized).pluck(:rowid, "rank")
    return none if fts_rows.empty?

    ids_in_rank_order = fts_rows.map(&:first)
    scope = where(account: account, id: ids_in_rank_order).includes(:idea, :board)
    scope = scope.where(board: board) if board.present?

    records = scope.to_a
    records.sort_by! { |r| ids_in_rank_order.index(r.id) }
    records.first(RESULT_LIMIT)
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

  def self.sanitize_query(terms)
    return "" if terms.blank?

    sanitized = terms.to_s.strip
    sanitized = sanitized.gsub(/[^\w\s"*-]/u, "")
    sanitized = fix_unbalanced_quotes(sanitized)
    sanitized = strip_bare_operators(sanitized)
    sanitized.squish
  end

  def self.fix_unbalanced_quotes(str)
    str.count('"').odd? ? str.delete('"') : str
  end
  private_class_method :fix_unbalanced_quotes

  def self.strip_bare_operators(str)
    str.gsub(/(?<!\w)[*-](?!\w)/, "")
  end
  private_class_method :strip_bare_operators

  private

    def upsert_fts_record
      Search::Record::Fts.upsert(id, title, content)
    end

    def remove_fts_record
      Search::Record::Fts.remove(id)
    end
end
