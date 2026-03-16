class CreateReadingProgresses < ActiveRecord::Migration[8.0]
  def change
    create_table :reading_progresses do |t|
      t.references :user, null: false, foreign_key: true
      t.references :book, null: false, foreign_key: true
      t.string :last_cfi
      t.jsonb :bookmarks, null: false, default: []

      t.timestamps
    end

    add_index :reading_progresses, [ :user_id, :book_id ], unique: true
  end
end
