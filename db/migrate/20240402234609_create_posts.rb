class CreatePosts < ActiveRecord::Migration[7.1]
  def change
    create_table :posts do |t|
      t.string :title
      t.references :status, null: false, foreign_key: true
      t.text :description

      t.timestamps
    end
  end
end
