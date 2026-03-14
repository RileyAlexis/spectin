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

ActiveRecord::Schema[8.0].define(version: 2026_03_14_203000) do
  # These are extensions that must be enabled in order to support this database
  enable_extension "pg_catalog.plpgsql"

  create_table "books", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.bigint "user_id", null: false
    t.string "title", null: false
    t.string "subtitle"
    t.string "authors", default: [], null: false, array: true
    t.string "publisher"
    t.string "language"
    t.string "isbn"
    t.string "identifier"
    t.string "source_format", default: "epub", null: false
    t.integer "spine_page_count"
    t.datetime "published_at"
    t.text "description"
    t.jsonb "metadata", default: {}, null: false
    t.binary "epub_data"
    t.string "epub_filename"
    t.string "epub_content_type"
    t.bigint "epub_byte_size"
    t.binary "cover_data"
    t.string "cover_filename"
    t.string "cover_content_type"
    t.bigint "cover_byte_size"
    t.index ["authors"], name: "index_books_on_authors", using: :gin
    t.index ["metadata"], name: "index_books_on_metadata", using: :gin
    t.index ["user_id", "identifier"], name: "index_books_on_user_id_and_identifier"
    t.index ["user_id", "title"], name: "index_books_on_user_id_and_title"
    t.index ["user_id"], name: "index_books_on_user_id"
  end

  create_table "users", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "email"
    t.string "display_name"
    t.index ["email"], name: "index_users_on_email", unique: true
  end

  add_foreign_key "books", "users"
end
