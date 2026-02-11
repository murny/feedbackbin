# frozen_string_literal: true

class CreateSearchRecordsFts < ActiveRecord::Migration[8.1]
  def up
    execute <<~SQL
      CREATE VIRTUAL TABLE search_records_fts USING fts5(
        title,
        content,
        tokenize='porter unicode61'
      )
    SQL
  end

  def down
    execute "DROP TABLE IF EXISTS search_records_fts"
  end
end
