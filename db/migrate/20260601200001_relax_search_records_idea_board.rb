# frozen_string_literal: true

class RelaxSearchRecordsIdeaBoard < ActiveRecord::Migration[8.2]
  def change
    change_column_null :search_records, :idea_id, true
    change_column_null :search_records, :board_id, true
  end
end
