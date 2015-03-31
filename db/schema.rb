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

ActiveRecord::Schema.define(version: 20150320235812) do

  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"
  enable_extension "hstore"

  create_table "addresses", force: :cascade do |t|
    t.string   "line1",                   null: false
    t.string   "line2"
    t.string   "line3"
    t.string   "line4"
    t.string   "locality"
    t.string   "region"
    t.string   "postcode"
    t.hstore   "metadata"
    t.integer  "country_id",              null: false
    t.integer  "site_id",                 null: false
    t.datetime "created_at",              null: false
    t.datetime "updated_at",              null: false
    t.integer  "customer_address_for_id"
    t.integer  "delivery_address_for_id"
  end

  add_index "addresses", ["country_id"], name: "index_addresses_on_country_id", using: :btree
  add_index "addresses", ["customer_address_for_id"], name: "index_addresses_on_customer_address_for_id", using: :btree
  add_index "addresses", ["delivery_address_for_id"], name: "index_addresses_on_delivery_address_for_id", using: :btree
  add_index "addresses", ["site_id"], name: "index_addresses_on_site_id", using: :btree

  create_table "blacklisted_countries", force: :cascade do |t|
    t.integer  "site_id",    null: false
    t.integer  "country_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  add_index "blacklisted_countries", ["country_id"], name: "index_blacklisted_countries_on_country_id", using: :btree
  add_index "blacklisted_countries", ["site_id"], name: "index_blacklisted_countries_on_site_id", using: :btree

  create_table "categories", force: :cascade do |t|
    t.integer  "parent_category_id"
    t.string   "name",                            null: false
    t.text     "description",                     null: false
    t.string   "generated_slug",                  null: false
    t.string   "specified_slug"
    t.hstore   "metadata"
    t.text     "tags",               default: [],              array: true
    t.datetime "created_at",                      null: false
    t.datetime "updated_at",                      null: false
    t.integer  "site_id",                         null: false
  end

  add_index "categories", ["parent_category_id"], name: "index_categories_on_parent_category_id", using: :btree
  add_index "categories", ["site_id"], name: "index_categories_on_site_id", using: :btree

  create_table "category_members", force: :cascade do |t|
    t.integer  "category_id", null: false
    t.integer  "product_id"
    t.integer  "variant_id"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "site_id",     null: false
  end

  add_index "category_members", ["site_id"], name: "index_category_members_on_site_id", using: :btree

  create_table "countries", force: :cascade do |t|
    t.string   "name",       null: false
    t.string   "iso_alpha2", null: false
    t.string   "iso_alpha3", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

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
    t.integer  "site_id",                       null: false
  end

  add_index "inventories", ["site_id"], name: "index_inventories_on_site_id", using: :btree

  create_table "order_lines", force: :cascade do |t|
    t.string   "customisation"
    t.integer  "price_cents",                null: false
    t.integer  "quantity",                   null: false
    t.integer  "site_id",                    null: false
    t.integer  "order_id",                   null: false
    t.integer  "product_id"
    t.integer  "variant_id"
    t.hstore   "metadata"
    t.text     "tags",          default: [],              array: true
    t.datetime "created_at",                 null: false
    t.datetime "updated_at",                 null: false
  end

  add_index "order_lines", ["order_id"], name: "index_order_lines_on_order_id", using: :btree
  add_index "order_lines", ["site_id"], name: "index_order_lines_on_site_id", using: :btree

  create_table "orders", force: :cascade do |t|
    t.integer  "price_cents",             null: false
    t.string   "status",      limit: 255, null: false
    t.hstore   "metadata"
    t.integer  "site_id",                 null: false
    t.datetime "created_at",              null: false
    t.datetime "updated_at",              null: false
  end

  add_index "orders", ["site_id"], name: "index_orders_on_site_id", using: :btree

  create_table "prioritized_countries", force: :cascade do |t|
    t.integer  "site_id",    null: false
    t.integer  "country_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  add_index "prioritized_countries", ["country_id"], name: "index_prioritized_countries_on_country_id", using: :btree
  add_index "prioritized_countries", ["site_id"], name: "index_prioritized_countries_on_site_id", using: :btree

  create_table "products", force: :cascade do |t|
    t.string   "name",                        null: false
    t.text     "description",                 null: false
    t.string   "generated_slug",              null: false
    t.string   "specified_slug"
    t.string   "gtin"
    t.string   "sku"
    t.integer  "price_cents",                 null: false
    t.integer  "grams"
    t.boolean  "active"
    t.datetime "not_before"
    t.datetime "not_after"
    t.json     "specifications"
    t.hstore   "metadata"
    t.text     "tags",           default: [],              array: true
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "site_id",                     null: false
  end

  add_index "products", ["site_id"], name: "index_products_on_site_id", using: :btree

  create_table "sites", force: :cascade do |t|
    t.string   "name",              null: false
    t.datetime "created_at",        null: false
    t.datetime "updated_at",        null: false
    t.string   "currency_iso_code", null: false
  end

  create_table "tenants", force: :cascade do |t|
    t.integer  "site_id",    null: false
    t.string   "identifier", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  add_index "tenants", ["identifier"], name: "index_tenants_on_identifier", using: :btree

  create_table "traits", force: :cascade do |t|
    t.string   "name",                        null: false
    t.string   "display_name",                null: false
    t.text     "description"
    t.hstore   "metadata"
    t.text     "default_values", default: [],              array: true
    t.text     "tags",           default: [],              array: true
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "site_id",                     null: false
  end

  add_index "traits", ["site_id"], name: "index_traits_on_site_id", using: :btree

  create_table "variants", force: :cascade do |t|
    t.integer  "product_id",                  null: false
    t.text     "description"
    t.string   "gtin"
    t.string   "sku"
    t.integer  "price_cents"
    t.integer  "grams"
    t.json     "specifications"
    t.hstore   "metadata"
    t.text     "tags",           default: [],              array: true
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "site_id",                     null: false
  end

  add_index "variants", ["site_id"], name: "index_variants_on_site_id", using: :btree

  create_table "variation_instances", force: :cascade do |t|
    t.integer  "variation_id", null: false
    t.integer  "variant_id",   null: false
    t.string   "value",        null: false
    t.hstore   "metadata"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "site_id",      null: false
  end

  add_index "variation_instances", ["site_id"], name: "index_variation_instances_on_site_id", using: :btree

  create_table "variations", force: :cascade do |t|
    t.integer  "product_id", null: false
    t.integer  "trait_id",   null: false
    t.integer  "order",      null: false
    t.hstore   "metadata"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "site_id",    null: false
  end

  add_index "variations", ["product_id", "order"], name: "index_variations_on_product_id_and_order", unique: true, using: :btree
  add_index "variations", ["site_id"], name: "index_variations_on_site_id", using: :btree

  create_table "version_associations", force: :cascade do |t|
    t.integer "version_id"
    t.string  "foreign_key_name", null: false
    t.integer "foreign_key_id"
  end

  add_index "version_associations", ["foreign_key_name", "foreign_key_id"], name: "index_version_associations_on_foreign_key", using: :btree
  add_index "version_associations", ["version_id"], name: "index_version_associations_on_version_id", using: :btree

  create_table "versions", force: :cascade do |t|
    t.string   "item_type",      null: false
    t.integer  "item_id",        null: false
    t.string   "event",          null: false
    t.string   "whodunnit"
    t.text     "object"
    t.datetime "created_at"
    t.integer  "transaction_id"
  end

  add_index "versions", ["item_type", "item_id", "transaction_id"], name: "index_versions_on_item_type_and_item_id_and_transaction_id", using: :btree

  create_table "whitelisted_countries", force: :cascade do |t|
    t.integer  "site_id",    null: false
    t.integer  "country_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  add_index "whitelisted_countries", ["country_id"], name: "index_whitelisted_countries_on_country_id", using: :btree
  add_index "whitelisted_countries", ["site_id"], name: "index_whitelisted_countries_on_site_id", using: :btree

  add_foreign_key "blacklisted_countries", "countries"
  add_foreign_key "blacklisted_countries", "sites"
  add_foreign_key "prioritized_countries", "countries"
  add_foreign_key "prioritized_countries", "sites"
  add_foreign_key "whitelisted_countries", "countries"
  add_foreign_key "whitelisted_countries", "sites"
end
