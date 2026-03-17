# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# This file is the source Rails uses to define your schema when running `bin/rails
# db:schema:load`. When creating a new database, `bin/rails db:schema:load` tends to
# be faster and is potentially less error prone than running all of your
# migrations from scratch. Old migrations may fail to apply correctly if those
# migrations use external dependencies or application code.
#
# It's strongly recommended that you check this file into your version control system.

ActiveRecord::Schema[8.1].define(version: 2026_03_17_195552) do
  # These are extensions that must be enabled in order to support this database
  enable_extension "pg_catalog.plpgsql"

  create_table "books", force: :cascade do |t|
    t.string "authors", default: [], null: false, array: true
    t.bigint "cover_byte_size"
    t.string "cover_content_type"
    t.binary "cover_data"
    t.string "cover_filename"
    t.datetime "created_at", null: false
    t.text "description"
    t.bigint "epub_byte_size"
    t.string "epub_content_type"
    t.binary "epub_data"
    t.string "epub_filename"
    t.string "identifier"
    t.string "isbn"
    t.string "language"
    t.jsonb "metadata", default: {}, null: false
    t.datetime "published_at"
    t.string "publisher"
    t.string "source_format", default: "epub", null: false
    t.integer "spine_page_count"
    t.string "subtitle"
    t.string "title", null: false
    t.datetime "updated_at", null: false
    t.bigint "user_id", null: false
    t.index ["authors"], name: "index_books_on_authors", using: :gin
    t.index ["metadata"], name: "index_books_on_metadata", using: :gin
    t.index ["user_id", "identifier"], name: "index_books_on_user_id_and_identifier"
    t.index ["user_id", "title"], name: "index_books_on_user_id_and_title"
    t.index ["user_id"], name: "index_books_on_user_id"
  end

  create_table "reading_progresses", force: :cascade do |t|
    t.bigint "book_id", null: false
    t.jsonb "bookmarks", default: [], null: false
    t.datetime "created_at", null: false
    t.string "last_cfi"
    t.datetime "updated_at", null: false
    t.bigint "user_id", null: false
    t.index ["book_id"], name: "index_reading_progresses_on_book_id"
    t.index ["user_id", "book_id"], name: "index_reading_progresses_on_user_id_and_book_id", unique: true
    t.index ["user_id"], name: "index_reading_progresses_on_user_id"
  end

  create_table "users", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.string "display_name"
    t.string "email"
    t.datetime "updated_at", null: false
    t.index ["email"], name: "index_users_on_email", unique: true
  end

  add_foreign_key "books", "users"
  add_foreign_key "reading_progresses", "books"
  add_foreign_key "reading_progresses", "users"
end
