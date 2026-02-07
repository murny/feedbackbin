# frozen_string_literal: true

class Search::Record::Fts < ApplicationRecord
  self.table_name = "search_records_fts"
  self.primary_key = "rowid"

  def self.upsert(rowid, title, content)
    connection.exec_query(
      "INSERT OR REPLACE INTO search_records_fts(rowid, title, content) VALUES (?, ?, ?)",
      "Search::Record::Fts Upsert",
      [ rowid, title, content ]
    )
  end

  def self.remove(rowid)
    connection.exec_query(
      "DELETE FROM search_records_fts WHERE rowid = ?",
      "Search::Record::Fts Remove",
      [ rowid ]
    )
  end

  def self.matching(query)
    where("search_records_fts MATCH ?", query)
  end

  def self.matching_with_highlights(query)
    select(
      "rowid",
      Arel.sql(sanitize_sql_array([
        "highlight(search_records_fts, 0, '<mark>', '</mark>') AS highlighted_title"
      ])),
      Arel.sql(sanitize_sql_array([
        "snippet(search_records_fts, 1, '<mark>', '</mark>', '...', 40) AS snippet"
      ]))
    ).where("search_records_fts MATCH ?", query)
  end
end
