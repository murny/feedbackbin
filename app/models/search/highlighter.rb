# frozen_string_literal: true

class Search::Highlighter
  def self.build_results(records, query)
    return [] if records.empty?

    sanitized = Search::Query.sanitize(query)
    return records.map { |r| Search::Result.new(record: r) } if sanitized.blank?

    fts_rows = Search::Record::Fts.matching_with_highlights(sanitized)
                                  .index_by { |row| row.rowid.to_i }

    records.map do |record|
      fts_row = fts_rows[record.id]
      Search::Result.new(
        record: record,
        highlighted_title: fts_row&.highlighted_title,
        snippet: fts_row&.snippet
      )
    end
  end
end
