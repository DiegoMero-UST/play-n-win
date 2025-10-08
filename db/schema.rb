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

ActiveRecord::Schema[8.0].define(version: 2025_10_07_141433) do
  # These are extensions that must be enabled in order to support this database
  enable_extension "pg_catalog.plpgsql"

  create_table "cards", force: :cascade do |t|
    t.bigint "game_id", null: false
    t.bigint "prize_id", null: false
    t.integer "position", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["game_id", "position"], name: "index_cards_on_game_id_and_position", unique: true
    t.index ["game_id", "prize_id"], name: "index_cards_on_game_id_and_prize_id"
    t.index ["game_id"], name: "index_cards_on_game_id"
    t.index ["prize_id"], name: "index_cards_on_prize_id"
  end

  create_table "games", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "token", null: false
    t.boolean "played", default: false
    t.boolean "form_submitted", default: false
    t.datetime "played_at"
    t.datetime "form_submitted_at"
    t.index ["token"], name: "index_games_on_token", unique: true
  end

  create_table "players", force: :cascade do |t|
    t.bigint "game_id", null: false
    t.integer "picked_card", null: false
    t.datetime "picked_at"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["game_id"], name: "index_players_on_game_id"
    t.index ["game_id"], name: "unique_players_game_id", unique: true
    t.index ["picked_card"], name: "index_players_on_picked_card"
  end

  create_table "prize_submissions", force: :cascade do |t|
    t.bigint "player_id", null: false
    t.string "first_name", null: false
    t.string "last_name", null: false
    t.string "email", null: false
    t.string "address1", null: false
    t.string "address2"
    t.string "city", null: false
    t.string "state", null: false
    t.string "country", null: false
    t.string "zip", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["email"], name: "index_prize_submissions_on_email"
    t.index ["player_id"], name: "index_prize_submissions_on_player_id"
    t.index ["player_id"], name: "unique_prize_submissions_player_id", unique: true
  end

  create_table "prizes", force: :cascade do |t|
    t.string "name", null: false
    t.text "description"
    t.boolean "active", default: true
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["name"], name: "index_prizes_on_name", unique: true
  end

  add_foreign_key "cards", "games"
  add_foreign_key "cards", "prizes"
  add_foreign_key "players", "games"
  add_foreign_key "prize_submissions", "players"
end
