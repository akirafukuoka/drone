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

ActiveRecord::Schema.define(version: 20140418015120) do

  create_table "coops", force: true do |t|
    t.integer  "oauth_id"
    t.integer  "coop_oauth_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "coops", ["coop_oauth_id"], name: "index_coops_on_coop_oauth_id", using: :btree
  add_index "coops", ["oauth_id"], name: "index_coops_on_oauth_id", using: :btree

  create_table "entries", force: true do |t|
    t.integer  "oauth_id"
    t.text     "description"
    t.text     "url"
    t.boolean  "publish",            default: false
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "image_file_name"
    t.string   "image_content_type"
    t.integer  "image_file_size"
    t.datetime "image_updated_at"
    t.datetime "posted_at"
    t.integer  "post_hour"
    t.integer  "post_min"
    t.integer  "ran",                default: 0
  end

  add_index "entries", ["oauth_id"], name: "index_entries_on_oauth_id", using: :btree

  create_table "follows", force: true do |t|
    t.integer  "oauth_id"
    t.string   "twitter_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "follows", ["oauth_id"], name: "index_follows_on_oauth_id", using: :btree

  create_table "oauths", force: true do |t|
    t.string   "provider"
    t.string   "token"
    t.string   "token_secret"
    t.string   "token_expires_at"
    t.string   "uid"
    t.string   "name"
    t.string   "image"
    t.boolean  "publish",          default: false
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "frequency",        default: "hour"
    t.integer  "base_hour",        default: 0
    t.integer  "base_min",         default: 0
    t.boolean  "random",           default: false
    t.boolean  "auto_follow",      default: false
    t.boolean  "auto_retweet",     default: false
    t.string   "week",             default: "1111111"
    t.string   "time",             default: "000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000"
    t.text     "bookmarklet"
  end

  create_table "posts", force: true do |t|
    t.integer  "oauth_id"
    t.integer  "entry_id"
    t.string   "posted_id"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.boolean  "error",      default: false
    t.string   "url"
  end

  add_index "posts", ["entry_id"], name: "index_posts_on_entry_id", using: :btree
  add_index "posts", ["oauth_id"], name: "index_posts_on_oauth_id", using: :btree

  create_table "retweets", force: true do |t|
    t.integer  "oauth_id"
    t.integer  "post_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "retweets", ["oauth_id"], name: "index_retweets_on_oauth_id", using: :btree
  add_index "retweets", ["post_id"], name: "index_retweets_on_post_id", using: :btree

  create_table "taggings", force: true do |t|
    t.integer  "tag_id"
    t.integer  "taggable_id"
    t.string   "taggable_type"
    t.integer  "tagger_id"
    t.string   "tagger_type"
    t.string   "context",       limit: 128
    t.datetime "created_at"
  end

  add_index "taggings", ["tag_id", "taggable_id", "taggable_type", "context", "tagger_id", "tagger_type"], name: "taggings_idx", unique: true, using: :btree

  create_table "tags", force: true do |t|
    t.string "name"
  end

  add_index "tags", ["name"], name: "index_tags_on_name", unique: true, using: :btree

end
