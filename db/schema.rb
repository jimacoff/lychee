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

ActiveRecord::Schema.define(version: 20141107232950) do

  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"
  enable_extension "hstore"

  create_table "inventories", force: true do |t|
    t.boolean  "tracked",       default: false, null: false
    t.integer  "quantity",      default: 0
    t.boolean  "back_orders",   default: false, null: false
    t.datetime "replenish_eta"
    t.datetime "exhausted_on"
    t.hstore   "metadata"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "products", force: true do |t|
    t.string   "name",                           null: false
    t.string   "generated_slug",                 null: false
    t.string   "specified_slug"
    t.text     "description",                    null: false
    t.string   "gtin",                           null: false
    t.string   "sku"
    t.integer  "price_cents",    default: 0,     null: false
    t.string   "price_currency", default: "USD", null: false
    t.integer  "grams"
    t.hstore   "specifications"
    t.boolean  "active"
    t.datetime "not_before"
    t.datetime "not_after"
    t.hstore   "variations"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "traits", force: true do |t|
    t.string   "name",                        null: false
    t.string   "display_name"
    t.text     "description"
    t.hstore   "metadata"
    t.text     "default_values", default: [],              array: true
    t.text     "tags",           default: [],              array: true
    t.integer  "parent_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

end
