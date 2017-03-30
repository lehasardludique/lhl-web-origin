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

ActiveRecord::Schema.define(version: 20170330143906) do

  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

  create_table "articles", force: :cascade do |t|
    t.integer  "user_id"
    t.string   "topic"
    t.integer  "main_gallery_id"
    t.integer  "resource_id"
    t.string   "title"
    t.string   "subtitle"
    t.text     "content"
    t.integer  "final_gallery_id"
    t.text     "exergue"
    t.string   "aside_link_1_data"
    t.string   "aside_link_2_data"
    t.string   "aside_link_3_data"
    t.boolean  "social_block"
    t.string   "event_link_data"
    t.string   "info_link_data"
    t.string   "media_link_fbk"
    t.string   "media_link_isg"
    t.string   "media_link_twt"
    t.string   "media_link_msk"
    t.string   "media_link_vid"
    t.string   "media_link_www"
    t.datetime "published_at"
    t.string   "title_slug"
    t.string   "date_slug"
    t.integer  "status"
    t.datetime "created_at",           null: false
    t.datetime "updated_at",           null: false
    t.bigint   "retargeting_pixel_id"
    t.index ["date_slug"], name: "index_articles_on_date_slug", using: :btree
    t.index ["final_gallery_id"], name: "index_articles_on_final_gallery_id", using: :btree
    t.index ["main_gallery_id"], name: "index_articles_on_main_gallery_id", using: :btree
    t.index ["resource_id"], name: "index_articles_on_resource_id", using: :btree
    t.index ["title_slug"], name: "index_articles_on_title_slug", using: :btree
    t.index ["user_id"], name: "index_articles_on_user_id", using: :btree
  end

  create_table "focus", force: :cascade do |t|
    t.string   "title"
    t.datetime "start"
    t.datetime "end"
    t.integer  "article_id"
    t.integer  "status",     default: 0
    t.datetime "created_at",             null: false
    t.datetime "updated_at",             null: false
    t.index ["article_id"], name: "index_focus_on_article_id", using: :btree
  end

  create_table "galleries", force: :cascade do |t|
    t.integer  "user_id"
    t.string   "name"
    t.integer  "category",   default: 0
    t.datetime "created_at",             null: false
    t.datetime "updated_at",             null: false
    t.index ["user_id"], name: "index_galleries_on_user_id", using: :btree
  end

  create_table "home_carousel_links", force: :cascade do |t|
    t.integer  "home_linkable_id"
    t.string   "home_linkable_type"
    t.integer  "rank",               default: 1
    t.string   "title"
    t.string   "subtitle"
    t.integer  "resource_id"
    t.integer  "status",             default: 0
    t.datetime "created_at",                     null: false
    t.datetime "updated_at",                     null: false
    t.index ["home_linkable_type", "home_linkable_id"], name: "index_home_carousel_links", using: :btree
    t.index ["resource_id"], name: "index_home_carousel_links_on_resource_id", using: :btree
  end

  create_table "image_ships", force: :cascade do |t|
    t.integer  "gallery_id"
    t.integer  "resource_id"
    t.integer  "rank",        default: 1
    t.datetime "created_at",              null: false
    t.datetime "updated_at",              null: false
    t.index ["gallery_id"], name: "index_image_ships_on_gallery_id", using: :btree
    t.index ["resource_id"], name: "index_image_ships_on_resource_id", using: :btree
  end

  create_table "pages", force: :cascade do |t|
    t.integer  "user_id"
    t.integer  "main_gallery_id"
    t.integer  "resource_id"
    t.string   "title"
    t.string   "subtitle"
    t.text     "content"
    t.integer  "final_gallery_id"
    t.text     "exergue"
    t.string   "aside_link_1_data"
    t.string   "aside_link_2_data"
    t.boolean  "social_block"
    t.string   "event_link_data"
    t.string   "info_link_data"
    t.string   "slug"
    t.integer  "status"
    t.datetime "created_at",           null: false
    t.datetime "updated_at",           null: false
    t.string   "aside_link_3_data"
    t.bigint   "retargeting_pixel_id"
    t.index ["final_gallery_id"], name: "index_pages_on_final_gallery_id", using: :btree
    t.index ["main_gallery_id"], name: "index_pages_on_main_gallery_id", using: :btree
    t.index ["resource_id"], name: "index_pages_on_resource_id", using: :btree
    t.index ["slug"], name: "index_pages_on_slug", using: :btree
    t.index ["user_id"], name: "index_pages_on_user_id", using: :btree
  end

  create_table "resources", force: :cascade do |t|
    t.integer  "user_id"
    t.string   "handle"
    t.string   "name"
    t.text     "notes"
    t.integer  "category",   default: 0
    t.datetime "created_at",             null: false
    t.datetime "updated_at",             null: false
    t.index ["user_id"], name: "index_resources_on_user_id", using: :btree
  end

  create_table "users", force: :cascade do |t|
    t.string   "email",                                    null: false
    t.string   "crypted_password"
    t.string   "salt"
    t.datetime "created_at",                               null: false
    t.datetime "updated_at",                               null: false
    t.string   "remember_me_token"
    t.datetime "remember_me_token_expires_at"
    t.datetime "last_login_at"
    t.datetime "last_logout_at"
    t.datetime "last_activity_at"
    t.string   "last_login_from_ip_address"
    t.string   "first_name"
    t.string   "last_name"
    t.integer  "role",                         default: 1
    t.integer  "status",                       default: 1
    t.index ["email"], name: "index_users_on_email", unique: true, using: :btree
    t.index ["last_logout_at", "last_activity_at"], name: "index_users_on_last_logout_at_and_last_activity_at", using: :btree
    t.index ["remember_me_token"], name: "index_users_on_remember_me_token", using: :btree
  end

  create_table "weez_events", force: :cascade do |t|
    t.bigint   "wid"
    t.string   "title"
    t.string   "image"
    t.jsonb    "data"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.datetime "date"
    t.string   "mini_site"
    t.index ["wid"], name: "index_weez_events_on_wid", using: :btree
  end

  add_foreign_key "articles", "galleries", column: "final_gallery_id"
  add_foreign_key "articles", "galleries", column: "main_gallery_id"
  add_foreign_key "articles", "resources"
  add_foreign_key "articles", "users"
  add_foreign_key "focus", "articles"
  add_foreign_key "galleries", "users"
  add_foreign_key "home_carousel_links", "resources"
  add_foreign_key "image_ships", "galleries"
  add_foreign_key "image_ships", "resources"
  add_foreign_key "pages", "galleries", column: "final_gallery_id"
  add_foreign_key "pages", "galleries", column: "main_gallery_id"
  add_foreign_key "pages", "resources"
  add_foreign_key "pages", "users"
  add_foreign_key "resources", "users"
end
