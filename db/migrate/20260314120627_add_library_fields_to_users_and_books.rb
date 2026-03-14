class AddLibraryFieldsToUsersAndBooks < ActiveRecord::Migration[8.0]
  def change
    change_table :users, bulk: true do |t|
      t.string :email
      t.string :display_name
    end

    add_index :users, :email, unique: true

    change_table :books, bulk: true do |t|
      t.references :user, null: false, foreign_key: true
      t.string :title, null: false
      t.string :subtitle
      t.string :authors, array: true, default: [], null: false
      t.string :publisher
      t.string :language
      t.string :isbn
      t.string :identifier
      t.string :source_format, null: false, default: "epub"
      t.integer :spine_page_count
      t.datetime :published_at
      t.text :description
      t.jsonb :metadata, null: false, default: {}
    end

    add_index :books, [ :user_id, :title ]
    add_index :books, [ :user_id, :identifier ]
    add_index :books, :authors, using: :gin
    add_index :books, :metadata, using: :gin
  end
end
