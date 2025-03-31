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

ActiveRecord::Schema[7.0].define(version: 2022_06_08_185819) do
  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

  create_table "event_times", force: :cascade do |t|
    t.integer "event_id"
    t.datetime "starting", precision: nil
    t.datetime "ending", precision: nil
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "day_of_week"
    t.boolean "all_day"
  end

  create_table "events", force: :cascade do |t|
    t.string "hosting_location"
    t.string "main_contact_person"
    t.string "contact_person_email"
    t.string "event_recurrence"
    t.text "event_description"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer "user_id"
    t.string "title"
    t.boolean "alcohol"
    t.boolean "red_light"
    t.boolean "fire_art"
    t.string "site_id"
    t.integer "heart_count", default: 0
    t.boolean "spectacle"
    t.boolean "crafting"
    t.boolean "food"
    t.boolean "sober"
  end

  create_table "hosted_files", force: :cascade do |t|
    t.string "name"
    t.text "content"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "users", force: :cascade do |t|
    t.string "provider"
    t.string "uid"
    t.string "name"
    t.text "image"
    t.text "token"
    t.datetime "expires_at", precision: nil
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "email"
    t.boolean "admin", default: false
    t.text "hearts"
  end

end
