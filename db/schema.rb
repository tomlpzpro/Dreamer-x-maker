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

ActiveRecord::Schema[8.1].define(version: 2026_06_05_104521) do
  # These are extensions that must be enabled in order to support this database
  enable_extension "pg_catalog.plpgsql"

  create_table "active_storage_attachments", force: :cascade do |t|
    t.bigint "blob_id", null: false
    t.datetime "created_at", null: false
    t.string "name", null: false
    t.bigint "record_id", null: false
    t.string "record_type", null: false
    t.index ["blob_id"], name: "index_active_storage_attachments_on_blob_id"
    t.index ["record_type", "record_id", "name", "blob_id"], name: "index_active_storage_attachments_uniqueness", unique: true
  end

  create_table "active_storage_blobs", force: :cascade do |t|
    t.bigint "byte_size", null: false
    t.string "checksum"
    t.string "content_type"
    t.datetime "created_at", null: false
    t.string "filename", null: false
    t.string "key", null: false
    t.text "metadata"
    t.string "service_name", null: false
    t.index ["key"], name: "index_active_storage_blobs_on_key", unique: true
  end

  create_table "active_storage_variant_records", force: :cascade do |t|
    t.bigint "blob_id", null: false
    t.string "variation_digest", null: false
    t.index ["blob_id", "variation_digest"], name: "index_active_storage_variant_records_uniqueness", unique: true
  end

  create_table "llm_chats", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.bigint "project_id", null: false
    t.datetime "updated_at", null: false
    t.index ["project_id"], name: "index_llm_chats_on_project_id"
  end

  create_table "llm_messages", force: :cascade do |t|
    t.string "content"
    t.datetime "created_at", null: false
    t.bigint "llm_chat_id", null: false
    t.string "role"
    t.datetime "updated_at", null: false
    t.index ["llm_chat_id"], name: "index_llm_messages_on_llm_chat_id"
  end

  create_table "maker_projects", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.integer "maker_id"
    t.bigint "project_id", null: false
    t.string "status"
    t.datetime "updated_at", null: false
    t.index ["project_id"], name: "index_maker_projects_on_project_id"
  end

  create_table "match_chats", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.bigint "maker_project_id", null: false
    t.datetime "updated_at", null: false
    t.index ["maker_project_id"], name: "index_match_chats_on_maker_project_id"
  end

  create_table "match_messages", force: :cascade do |t|
    t.string "content"
    t.datetime "created_at", null: false
    t.bigint "match_chat_id", null: false
    t.boolean "read"
    t.datetime "updated_at", null: false
    t.integer "user_id"
    t.index ["match_chat_id"], name: "index_match_messages_on_match_chat_id"
  end

  create_table "projects", force: :cascade do |t|
    t.integer "budget"
    t.datetime "created_at", null: false
    t.string "deadline"
    t.string "description"
    t.integer "dreamer_id"
    t.string "title"
    t.datetime "updated_at", null: false
  end

  create_table "users", force: :cascade do |t|
    t.string "adresse"
    t.datetime "created_at", null: false
    t.string "email", default: "", null: false
    t.string "encrypted_password", default: "", null: false
    t.string "phone_number"
    t.string "profile_picture_url"
    t.datetime "remember_created_at"
    t.datetime "reset_password_sent_at"
    t.string "reset_password_token"
    t.string "role"
    t.string "skills"
    t.datetime "updated_at", null: false
    t.string "username"
    t.index ["email"], name: "index_users_on_email", unique: true
    t.index ["reset_password_token"], name: "index_users_on_reset_password_token", unique: true
  end

  add_foreign_key "active_storage_attachments", "active_storage_blobs", column: "blob_id"
  add_foreign_key "active_storage_variant_records", "active_storage_blobs", column: "blob_id"
  add_foreign_key "llm_chats", "projects"
  add_foreign_key "llm_messages", "llm_chats"
  add_foreign_key "maker_projects", "projects"
  add_foreign_key "maker_projects", "users", column: "maker_id"
  add_foreign_key "match_chats", "maker_projects"
  add_foreign_key "match_messages", "match_chats"
  add_foreign_key "match_messages", "users"
  add_foreign_key "projects", "users", column: "dreamer_id"
end
