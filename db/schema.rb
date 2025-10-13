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

ActiveRecord::Schema[8.0].define(version: 2025_10_13_055543) do
  # These are extensions that must be enabled in order to support this database
  enable_extension "pg_catalog.plpgsql"

  create_table "active_storage_attachments", force: :cascade do |t|
    t.string "name", null: false
    t.string "record_type", null: false
    t.bigint "record_id", null: false
    t.bigint "blob_id", null: false
    t.datetime "created_at", null: false
    t.index ["blob_id"], name: "index_active_storage_attachments_on_blob_id"
    t.index ["record_type", "record_id", "name", "blob_id"], name: "index_active_storage_attachments_uniqueness", unique: true
  end

  create_table "active_storage_blobs", force: :cascade do |t|
    t.string "key", null: false
    t.string "filename", null: false
    t.string "content_type"
    t.text "metadata"
    t.string "service_name", null: false
    t.bigint "byte_size", null: false
    t.string "checksum"
    t.datetime "created_at", null: false
    t.index ["key"], name: "index_active_storage_blobs_on_key", unique: true
  end

  create_table "active_storage_variant_records", force: :cascade do |t|
    t.bigint "blob_id", null: false
    t.string "variation_digest", null: false
    t.index ["blob_id", "variation_digest"], name: "index_active_storage_variant_records_uniqueness", unique: true
  end

  create_table "administrators", force: :cascade do |t|
    t.string "email", default: "", null: false
    t.string "encrypted_password", default: "", null: false
    t.string "reset_password_token"
    t.datetime "reset_password_sent_at", precision: nil
    t.datetime "remember_created_at", precision: nil
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["email"], name: "index_administrators_on_email", unique: true
    t.index ["reset_password_token"], name: "index_administrators_on_reset_password_token", unique: true
  end

  create_table "admins", force: :cascade do |t|
    t.string "name"
    t.string "email", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "encrypted_password", default: "", null: false
    t.string "role", default: "admin", null: false
    t.boolean "active", default: true, null: false
    t.string "reset_password_token"
    t.datetime "reset_password_sent_at"
    t.datetime "remember_created_at"
    t.index ["email"], name: "index_admins_on_email", unique: true
    t.index ["reset_password_token"], name: "index_admins_on_reset_password_token", unique: true
  end

  create_table "comments", force: :cascade do |t|
    t.text "body", null: false
    t.bigint "user_id"
    t.bigint "admin_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.bigint "seller_id"
    t.bigint "host_id"
    t.index ["user_id"], name: "index_comments_on_user_id"
  end

  create_table "event_views", force: :cascade do |t|
    t.bigint "event_id", null: false
    t.string "ip_address"
    t.datetime "viewed_at"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["event_id", "ip_address", "viewed_at"], name: "index_event_views_on_event_id_and_ip_address_and_viewed_at"
    t.index ["event_id"], name: "index_event_views_on_event_id"
    t.index ["viewed_at"], name: "index_event_views_on_viewed_at"
  end

  create_table "events", force: :cascade do |t|
    t.string "title"
    t.text "description"
    t.datetime "start_time"
    t.datetime "end_time"
    t.string "venue"
    t.string "address"
    t.float "latitude"
    t.float "longitude"
    t.string "capacity"
    t.boolean "is_online"
    t.string "online_url"
    t.boolean "is_free"
    t.string "price"
    t.string "organizer"
    t.string "contact_info"
    t.string "website"
    t.integer "status"
    t.string "image"
    t.string "video"
    t.integer "category_id"
    t.bigint "facility_id"
    t.bigint "seller_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "prefecture"
    t.bigint "host_id"
    t.boolean "is_featured", default: false, null: false
    t.index ["facility_id"], name: "index_events_on_facility_id"
    t.index ["host_id"], name: "index_events_on_host_id"
    t.index ["seller_id"], name: "index_events_on_seller_id"
  end

  create_table "facilities", force: :cascade do |t|
    t.string "name", default: ""
    t.text "description", default: ""
    t.string "address", default: ""
    t.float "latitude"
    t.float "longitude"
    t.string "phone_number", default: ""
    t.string "email"
    t.string "website", default: ""
    t.integer "facility_type"
    t.string "image"
    t.string "video"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "faqs", force: :cascade do |t|
    t.string "question", null: false
    t.string "note_url", null: false
    t.integer "order", default: 0
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "hosts", force: :cascade do |t|
    t.string "email", default: "", null: false
    t.string "encrypted_password", default: "", null: false
    t.string "reset_password_token"
    t.datetime "reset_password_sent_at"
    t.datetime "remember_created_at"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.text "admin_comment"
    t.string "name"
    t.text "description"
    t.string "address"
    t.string "phone_number"
    t.string "website"
    t.string "image"
    t.string "video"
    t.string "business_hours_days"
    t.time "business_hours_start"
    t.time "business_hours_end"
    t.text "past_exhibitions_names"
    t.text "past_exhibitions_dates"
    t.text "sns_accounts_types"
    t.text "sns_accounts_urls"
    t.bigint "facility_id"
    t.text "news"
    t.text "topics"
    t.text "goods_introduction"
    t.text "goods_introduction_1"
    t.text "goods_introduction_2"
    t.text "goods_introduction_3"
    t.text "goods_introduction_4"
    t.boolean "editable", default: true
    t.string "contact_link"
    t.string "slug"
    t.index ["email"], name: "index_hosts_on_email", unique: true
    t.index ["facility_id"], name: "index_hosts_on_facility_id"
    t.index ["reset_password_token"], name: "index_hosts_on_reset_password_token", unique: true
    t.index ["slug"], name: "index_hosts_on_slug", unique: true
  end

  create_table "notices", force: :cascade do |t|
    t.string "title"
    t.text "content"
    t.datetime "published_at"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "regions", force: :cascade do |t|
    t.string "name"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "sellers", force: :cascade do |t|
    t.string "email", default: "", null: false
    t.string "encrypted_password", default: "", null: false
    t.string "reset_password_token"
    t.datetime "reset_password_sent_at"
    t.datetime "remember_created_at"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "name"
    t.text "description"
    t.string "address"
    t.string "phone_number"
    t.string "website"
    t.string "image"
    t.string "video"
    t.string "business_hours_days"
    t.time "business_hours_start"
    t.time "business_hours_end"
    t.text "past_exhibitions_names"
    t.text "past_exhibitions_dates"
    t.text "sns_accounts_types"
    t.text "sns_accounts_urls"
    t.text "admin_comment"
    t.bigint "facility_id"
    t.boolean "editable", default: true
    t.index ["email"], name: "index_sellers_on_email", unique: true
    t.index ["facility_id"], name: "index_sellers_on_facility_id"
    t.index ["reset_password_token"], name: "index_sellers_on_reset_password_token", unique: true
  end

  create_table "solid_queue_jobs", force: :cascade do |t|
    t.string "queue_name", null: false
    t.string "class_name", null: false
    t.json "arguments"
    t.datetime "scheduled_at"
    t.datetime "started_at"
    t.datetime "finished_at"
    t.datetime "failed_at"
    t.integer "attempts", default: 0, null: false
    t.text "error_message"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["class_name"], name: "index_solid_queue_jobs_on_class_name"
    t.index ["queue_name"], name: "index_solid_queue_jobs_on_queue_name"
    t.index ["scheduled_at"], name: "index_solid_queue_jobs_on_scheduled_at"
  end

  create_table "topics", force: :cascade do |t|
    t.string "title"
    t.text "content"
    t.bigint "host_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["host_id"], name: "index_topics_on_host_id"
  end

  create_table "users", force: :cascade do |t|
    t.string "email", default: "", null: false
    t.string "encrypted_password", default: "", null: false
    t.string "reset_password_token"
    t.datetime "reset_password_sent_at"
    t.datetime "remember_created_at"
    t.string "role"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.date "trial_end_date"
    t.string "name"
    t.index ["email"], name: "index_users_on_email", unique: true
    t.index ["reset_password_token"], name: "index_users_on_reset_password_token", unique: true
  end

  add_foreign_key "active_storage_attachments", "active_storage_blobs", column: "blob_id"
  add_foreign_key "active_storage_variant_records", "active_storage_blobs", column: "blob_id"
  add_foreign_key "event_views", "events"
  add_foreign_key "events", "facilities"
  add_foreign_key "events", "hosts"
  add_foreign_key "events", "sellers"
  add_foreign_key "hosts", "facilities"
  add_foreign_key "sellers", "facilities"
  add_foreign_key "topics", "hosts"
end
