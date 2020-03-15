# encoding: UTF-8
# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# Note that this schema.rb definition is the authoritative source for your
# database schema. If you need to create the application database on another
# system, you should be using db:schema:load, not running all the migrations
# from scratch. The latter is a flawed and unsustainable approach (the more migrations
# you'll amass, the slower it'll run and the greater likelihood for issues).
#
# It's strongly recommended that you check this file into your version control system.

ActiveRecord::Schema.define(version: 20180423014604) do

  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

  create_table "event_times", force: :cascade do |t|
    t.integer  "event_id"
    t.datetime "starting"
    t.datetime "ending"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "day_of_week"
    t.boolean  "all_day"
  end

  create_table "events", force: :cascade do |t|
    t.string   "hosting_location"
    t.string   "main_contact_person"
    t.string   "contact_person_email"
    t.string   "event_recurrence"
    t.text     "event_description"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "user_id"
    t.string   "title"
    t.boolean  "alcohol"
    t.boolean  "red_light"
    t.boolean  "fire_art"
    t.string   "site_id"
    t.integer  "heart_count",          default: 0
  end

  create_table "users", force: :cascade do |t|
    t.string   "provider"
    t.string   "uid"
    t.string   "name"
    t.string   "image"
    t.string   "token"
    t.datetime "expires_at"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "email"
    t.boolean  "admin",      default: false
    t.text     "hearts"
  end

end
