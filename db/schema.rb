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

ActiveRecord::Schema[7.1].define(version: 2024_06_13_200126) do
  create_table "directories", force: :cascade do |t|
    t.string "path", null: false
    t.integer "discourse_category_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["discourse_category_id"], name: "index_directories_on_discourse_category_id"
    t.index ["path"], name: "index_directories_on_path", unique: true
  end

  create_table "discourse_categories", force: :cascade do |t|
    t.string "name", null: false
    t.integer "discourse_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "slug"
    t.index ["discourse_id"], name: "index_discourse_categories_on_discourse_id", unique: true
    t.index ["name"], name: "index_discourse_categories_on_name", unique: true
  end

  create_table "discourse_topics", force: :cascade do |t|
    t.string "discourse_url", null: false
    t.integer "discourse_id", null: false
    t.integer "discourse_post_id", null: false
    t.integer "note_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["discourse_id"], name: "index_discourse_topics_on_discourse_id", unique: true
    t.index ["discourse_post_id"], name: "index_discourse_topics_on_discourse_post_id", unique: true
    t.index ["discourse_url"], name: "index_discourse_topics_on_discourse_url", unique: true
    t.index ["note_id"], name: "index_discourse_topics_on_note_id"
  end

  create_table "notes", force: :cascade do |t|
    t.string "title", null: false
    t.integer "directory_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["directory_id"], name: "index_notes_on_directory_id"
    t.index ["title"], name: "index_notes_on_title", unique: true
  end

  add_foreign_key "directories", "discourse_categories"
  add_foreign_key "discourse_topics", "notes"
  add_foreign_key "notes", "directories"
end
