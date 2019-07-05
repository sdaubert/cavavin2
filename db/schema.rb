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

ActiveRecord::Schema.define(version: 2019_06_25_195526) do

  create_table "bottle_racks", force: :cascade do |t|
    t.string "name"
    t.integer "lines"
    t.integer "columns"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "colors", force: :cascade do |t|
    t.string "name"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "countries", force: :cascade do |t|
    t.string "name"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "millesimes", force: :cascade do |t|
    t.integer "year"
    t.integer "garde"
    t.integer "wine_id"
    t.text "notes"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "producers", force: :cascade do |t|
    t.string "name"
    t.string "address"
    t.string "zip"
    t.string "city"
    t.integer "country_id"
    t.string "phone"
    t.string "web"
    t.string "email"
    t.text "notes"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "providers", force: :cascade do |t|
    t.string "name"
    t.string "address"
    t.string "zip"
    t.string "city"
    t.integer "country_id"
    t.string "phone"
    t.string "web"
    t.string "email"
    t.text "notes"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "regions", force: :cascade do |t|
    t.integer "country_id"
    t.string "name"
    t.integer "parent_id"
    t.integer "lft", null: false
    t.integer "rgt", null: false
    t.integer "depth", default: 0, null: false
    t.integer "children_count", default: 0, null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["country_id"], name: "index_regions_on_country_id"
    t.index ["lft"], name: "index_regions_on_lft"
    t.index ["parent_id"], name: "index_regions_on_parent_id"
    t.index ["rgt"], name: "index_regions_on_rgt"
  end

  create_table "wines", force: :cascade do |t|
    t.string "domain"
    t.boolean "effervescent"
    t.boolean "organic"
    t.integer "color_id"
    t.integer "region_id"
    t.integer "producer_id"
    t.integer "provider_id"
    t.text "notes"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "wlogs", force: :cascade do |t|
    t.integer "millesime_id"
    t.date "date"
    t.string "mvt_type"
    t.integer "quantity"
    t.decimal "price", precision: 8, scale: 2
    t.text "notes"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

end
