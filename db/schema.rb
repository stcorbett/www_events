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

ActiveRecord::Schema.define(version: 20141025020407) do

  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

  create_table "events", force: true do |t|
    t.string   "hosting_location"
    t.string   "main_contact_person"
    t.string   "contact_person_email"
    t.string   "event_recurrence"
    t.datetime "single_occurrence_start"
    t.integer  "single_occurrence_duration_minutes"
    t.datetime "wednesday_start"
    t.datetime "thursday_start"
    t.datetime "friday_start"
    t.datetime "saturday_start"
    t.datetime "sunday_start"
    t.float    "wednesday_duration"
    t.float    "thursday_duration"
    t.float    "friday_duration"
    t.float    "saturday_duration"
    t.float    "sunday_duration"
    t.text     "event_description"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

end
