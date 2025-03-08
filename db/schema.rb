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

ActiveRecord::Schema[8.0].define(version: 2025_03_07_232629) do
  # These are extensions that must be enabled in order to support this database
  enable_extension "pg_catalog.plpgsql"

  create_table "events", force: :cascade do |t|
    t.string "title"
    t.text "description"
    t.datetime "start_time"
    t.datetime "end_time"
    t.string "venue"
    t.string "address"
    t.float "latitude"
    t.float "longitude"
    t.integer "capacity"
    t.boolean "is_online"
    t.string "online_url"
    t.boolean "is_free"
    t.decimal "price"
    t.string "organizer"
    t.string "contact_info"
    t.string "website"
    t.integer "status"
    t.string "image"
    t.string "video"
    t.integer "category_id"
    t.integer "facility_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "facilities", force: :cascade do |t|
    t.string "name"
    t.text "description"
    t.string "address"
    t.float "latitude"
    t.float "longitude"
    t.string "phone_number"
    t.string "email"
    t.string "website"
    t.integer "facility_type"
    t.string "image"
    t.string "video"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end
end
