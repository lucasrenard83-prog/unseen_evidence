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

ActiveRecord::Schema[7.1].define(version: 2025_12_08_151246) do
  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

  create_table "games", force: :cascade do |t|
    t.bigint "user_id", null: false
    t.string "scenario"
    t.string "secret_scenario"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer "elapsed_time", default: 0
    t.index ["user_id"], name: "index_games_on_user_id"
  end

  create_table "items", force: :cascade do |t|
    t.string "name"
    t.string "description"
    t.bigint "room_id"
    t.string "picture_url"
    t.boolean "found"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.bigint "persona_id"
    t.bigint "game_id", null: false
    t.index ["game_id"], name: "index_items_on_game_id"
    t.index ["persona_id"], name: "index_items_on_persona_id"
    t.index ["room_id"], name: "index_items_on_room_id"
  end

  create_table "messages", force: :cascade do |t|
    t.string "content"
    t.string "role"
    t.bigint "game_id", null: false
    t.bigint "room_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.bigint "persona_id"
    t.index ["game_id"], name: "index_messages_on_game_id"
    t.index ["persona_id"], name: "index_messages_on_persona_id"
    t.index ["room_id"], name: "index_messages_on_room_id"
  end

  create_table "personas", force: :cascade do |t|
    t.string "name"
    t.string "description"
    t.string "ai_guideline"
    t.bigint "room_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.boolean "item_given"
    t.index ["room_id"], name: "index_personas_on_room_id"
  end

  create_table "rooms", force: :cascade do |t|
    t.string "name"
    t.string "description"
    t.string "ai_guideline"
    t.string "before_picture_url"
    t.string "after_picture_url"
    t.boolean "item_found"
    t.bigint "game_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer "position"
    t.boolean "open"
    t.index ["game_id"], name: "index_rooms_on_game_id"
  end

  create_table "users", force: :cascade do |t|
    t.string "email", default: "", null: false
    t.string "encrypted_password", default: "", null: false
    t.string "reset_password_token"
    t.datetime "reset_password_sent_at"
    t.datetime "remember_created_at"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["email"], name: "index_users_on_email", unique: true
    t.index ["reset_password_token"], name: "index_users_on_reset_password_token", unique: true
  end

  add_foreign_key "games", "users"
  add_foreign_key "items", "games"
  add_foreign_key "items", "personas"
  add_foreign_key "items", "rooms"
  add_foreign_key "messages", "games"
  add_foreign_key "messages", "personas"
  add_foreign_key "messages", "rooms"
  add_foreign_key "personas", "rooms"
  add_foreign_key "rooms", "games"
end
