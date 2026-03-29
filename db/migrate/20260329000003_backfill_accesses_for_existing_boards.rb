# frozen_string_literal: true

class BackfillAccessesForExistingBoards < ActiveRecord::Migration[8.2]
  def up
    execute <<~SQL
      INSERT INTO accesses (account_id, board_id, user_id, involvement, accessed_at, created_at, updated_at)
      SELECT boards.account_id, boards.id, users.id, 0, CURRENT_TIMESTAMP, CURRENT_TIMESTAMP, CURRENT_TIMESTAMP
      FROM boards
      INNER JOIN users ON users.account_id = boards.account_id AND users.active = 1
      WHERE NOT EXISTS (
        SELECT 1 FROM accesses
        WHERE accesses.board_id = boards.id AND accesses.user_id = users.id
      )
    SQL
  end

  def down
    execute "DELETE FROM accesses"
  end
end
