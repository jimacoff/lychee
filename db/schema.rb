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

ActiveRecord::Schema.define(version: 20150117101406) do

  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"
  enable_extension "hstore"

  create_table "categories", force: :cascade do |t|
    t.integer  "parent_category_id"
    t.string   "name"
    t.text     "description"
    t.string   "generated_slug",     null: false
    t.string   "specified_slug"
    t.hstore   "metadata"
    t.datetime "created_at",         null: false
    t.datetime "updated_at",         null: false
  end

  add_index "categories", ["parent_category_id"], name: "index_categories_on_parent_category_id", using: :btree

  create_table "categories_products", id: false, force: :cascade do |t|
    t.integer "category_id"
    t.integer "product_id"
  end

  add_index "categories_products", ["category_id", "product_id"], name: "index_categories_products_on_category_id_and_product_id", using: :btree

  create_table "categories_variants", id: false, force: :cascade do |t|
    t.integer "category_id"
    t.integer "variant_id"
  end

  add_index "categories_variants", ["category_id", "variant_id"], name: "index_categories_variants_on_category_id_and_variant_id", using: :btree

  create_table "inventories", force: :cascade do |t|
    t.boolean  "tracked",       default: false, null: false
    t.integer  "quantity",      default: 0
    t.boolean  "back_orders",   default: false, null: false
    t.datetime "replenish_eta"
    t.datetime "exhausted_on"
    t.hstore   "metadata"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "product_id"
    t.integer  "variant_id"
  end

  create_table "products", force: :cascade do |t|
    t.string   "name",                           null: false
    t.text     "description",                    null: false
    t.string   "generated_slug",                 null: false
    t.string   "specified_slug"
    t.string   "gtin"
    t.string   "sku"
    t.integer  "price_cents",    default: 0,     null: false
    t.string   "price_currency", default: "USD", null: false
    t.integer  "grams"
    t.boolean  "active"
    t.datetime "not_before"
    t.datetime "not_after"
    t.json     "specifications"
    t.hstore   "metadata"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "traits", force: :cascade do |t|
    t.string   "name",                        null: false
    t.string   "display_name"
    t.text     "description"
    t.hstore   "metadata"
    t.text     "default_values", default: [],              array: true
    t.text     "tags",           default: [],              array: true
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "variants", force: :cascade do |t|
    t.integer  "product_id",     null: false
    t.text     "description"
    t.string   "gtin"
    t.string   "sku"
    t.integer  "price_cents"
    t.string   "price_currency"
    t.integer  "grams"
    t.json     "specifications"
    t.hstore   "metadata"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "variation_instances", force: :cascade do |t|
    t.integer  "variation_id"
    t.integer  "variant_id"
    t.string   "value"
    t.hstore   "metadata"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "variations", force: :cascade do |t|
    t.integer  "product_id", null: false
    t.integer  "trait_id",   null: false
    t.integer  "order",      null: false
    t.hstore   "metadata"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

end
