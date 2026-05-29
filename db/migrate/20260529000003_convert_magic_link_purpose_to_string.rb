# frozen_string_literal: true

class ConvertMagicLinkPurposeToString < ActiveRecord::Migration[8.2]
  MAPPING = { 0 => "sign_in", 1 => "sign_up" }.freeze

  def up
    add_column :magic_links, :purpose_tmp, :string, default: "sign_in", null: false
    MAPPING.each { |ordinal, label| execute("UPDATE magic_links SET purpose_tmp = '#{label}' WHERE purpose = #{ordinal}") }
    remove_column :magic_links, :purpose
    rename_column :magic_links, :purpose_tmp, :purpose
  end

  def down
    add_column :magic_links, :purpose_tmp, :integer, default: 0, null: false
    MAPPING.each { |ordinal, label| execute("UPDATE magic_links SET purpose_tmp = #{ordinal} WHERE purpose = '#{label}'") }
    remove_column :magic_links, :purpose
    rename_column :magic_links, :purpose_tmp, :purpose
  end
end
