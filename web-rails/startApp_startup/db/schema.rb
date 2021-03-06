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

ActiveRecord::Schema.define(version: 20170306034626) do

  create_table "mobile_app_screens", force: :cascade do |t|
    t.string   "mobile_app"
    t.string   "name"
    t.datetime "created_at",    null: false
    t.datetime "updated_at",    null: false
    t.integer  "mobile_app_id"
    t.text     "raw_html"
    t.text     "editor_html"
    t.text     "wsURL"
  end

  add_index "mobile_app_screens", ["mobile_app_id"], name: "index_mobile_app_screens_on_mobile_app_id"

  create_table "mobile_apps", force: :cascade do |t|
    t.string   "title"
    t.text     "description"
    t.datetime "created_at",  null: false
    t.datetime "updated_at",  null: false
    t.string   "apptype"
    t.integer  "user_id"
    t.string   "port"
    t.string   "token"
  end

  add_index "mobile_apps", ["user_id"], name: "index_mobile_apps_on_user_id"

  create_table "notifications", force: :cascade do |t|
    t.string   "message"
    t.integer  "mobile_app_id"
    t.datetime "action_date"
    t.datetime "created_at",    null: false
    t.datetime "updated_at",    null: false
    t.boolean  "sent"
    t.string   "title"
  end

  create_table "users", force: :cascade do |t|
    t.string   "email",                  default: "", null: false
    t.string   "encrypted_password",     default: "", null: false
    t.string   "reset_password_token"
    t.datetime "reset_password_sent_at"
    t.datetime "remember_created_at"
    t.integer  "sign_in_count",          default: 0,  null: false
    t.datetime "current_sign_in_at"
    t.datetime "last_sign_in_at"
    t.string   "current_sign_in_ip"
    t.string   "last_sign_in_ip"
    t.datetime "created_at",                          null: false
    t.datetime "updated_at",                          null: false
    t.string   "provider"
    t.string   "uid"
  end

  add_index "users", ["email"], name: "index_users_on_email", unique: true
  add_index "users", ["reset_password_token"], name: "index_users_on_reset_password_token", unique: true

  create_table "versions", force: :cascade do |t|
    t.string   "description"
    t.integer  "mobile_app_id"
    t.datetime "created_at",    null: false
    t.datetime "updated_at",    null: false
  end

end
