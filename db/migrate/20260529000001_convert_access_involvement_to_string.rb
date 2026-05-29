# frozen_string_literal: true

class ConvertAccessInvolvementToString < ActiveRecord::Migration[8.2]
  MAPPING = { 0 => "access_only", 1 => "watching" }.freeze

  def up
    add_column :accesses, :involvement_tmp, :string, default: "access_only", null: false
    MAPPING.each { |ordinal, label| execute("UPDATE accesses SET involvement_tmp = '#{label}' WHERE involvement = #{ordinal}") }
    remove_column :accesses, :involvement
    rename_column :accesses, :involvement_tmp, :involvement
  end

  def down
    add_column :accesses, :involvement_tmp, :integer, default: 0, null: false
    MAPPING.each { |ordinal, label| execute("UPDATE accesses SET involvement_tmp = #{ordinal} WHERE involvement = '#{label}'") }
    remove_column :accesses, :involvement
    rename_column :accesses, :involvement_tmp, :involvement
  end
end
