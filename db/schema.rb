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

ActiveRecord::Schema.define(version: 20151013041051) do

  create_table "carts", force: :cascade do |t|
    t.integer  "num_items"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "mp3s", force: :cascade do |t|
    t.string   "title"
    t.string   "artist"
    t.string   "length"
    t.string   "file_size"
    t.string   "file_format"
    t.string   "download_path"
    t.datetime "created_at",     null: false
    t.datetime "updated_at",     null: false
    t.integer  "cart_id"
    t.boolean  "download_ready"
  end

  add_index "mp3s", ["cart_id"], name: "index_mp3s_on_cart_id"

  create_table "videos", force: :cascade do |t|
    t.string   "title"
    t.string   "description"
    t.string   "embed_url"
    t.string   "thumbnail"
    t.datetime "created_at",  null: false
    t.datetime "updated_at",  null: false
    t.string   "vid_id"
    t.integer  "cart_id"
    t.string   "duration"
  end

end
