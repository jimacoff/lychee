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

ActiveRecord::Schema.define(version: 20151005100748) do

  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"
  enable_extension "hstore"
  enable_extension "ltree"

  create_table "addresses", id: :bigserial, force: :cascade do |t|
    t.string   "line1",                null: false
    t.string   "line2"
    t.string   "line3"
    t.string   "line4"
    t.string   "locality"
    t.string   "postcode"
    t.hstore   "metadata"
    t.integer  "country_id", limit: 8, null: false
    t.integer  "site_id",    limit: 8, null: false
    t.datetime "created_at",           null: false
    t.datetime "updated_at",           null: false
    t.integer  "state_id",   limit: 8
  end

  add_index "addresses", ["country_id"], name: "index_addresses_on_country_id", using: :btree
  add_index "addresses", ["site_id"], name: "index_addresses_on_site_id", using: :btree
  add_index "addresses", ["state_id"], name: "index_addresses_on_state_id", using: :btree

  create_table "blacklisted_countries", id: :bigserial, force: :cascade do |t|
    t.integer  "site_id",    limit: 8, null: false
    t.integer  "country_id", limit: 8, null: false
    t.datetime "created_at",           null: false
    t.datetime "updated_at",           null: false
  end

  add_index "blacklisted_countries", ["country_id"], name: "index_blacklisted_countries_on_country_id", using: :btree
  add_index "blacklisted_countries", ["site_id"], name: "index_blacklisted_countries_on_site_id", using: :btree

  create_table "categories", id: :bigserial, force: :cascade do |t|
    t.integer  "parent_category_id", limit: 8
    t.string   "name",                                        null: false
    t.text     "description",                                 null: false
    t.string   "generated_slug",                              null: false
    t.string   "specified_slug"
    t.hstore   "metadata"
    t.text     "tags",                         default: [],                array: true
    t.datetime "created_at",                                  null: false
    t.datetime "updated_at",                                  null: false
    t.integer  "site_id",            limit: 8,                null: false
    t.boolean  "enabled",                      default: true, null: false
  end

  add_index "categories", ["parent_category_id"], name: "index_categories_on_parent_category_id", using: :btree
  add_index "categories", ["site_id", "generated_slug"], name: "index_categories_on_site_id_and_generated_slug", unique: true, using: :btree
  add_index "categories", ["site_id", "name"], name: "index_categories_on_site_id_and_name", unique: true, using: :btree
  add_index "categories", ["site_id", "specified_slug"], name: "index_categories_on_site_id_and_specified_slug", unique: true, using: :btree
  add_index "categories", ["site_id"], name: "index_categories_on_site_id", using: :btree

  create_table "category_members", id: :bigserial, force: :cascade do |t|
    t.integer  "category_id", limit: 8, null: false
    t.integer  "product_id",  limit: 8
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "site_id",     limit: 8, null: false
    t.string   "description"
    t.integer  "order",                 null: false
  end

  add_index "category_members", ["product_id"], name: "index_category_members_on_product_id", using: :btree
  add_index "category_members", ["site_id"], name: "index_category_members_on_site_id", using: :btree

  create_table "countries", id: :bigserial, force: :cascade do |t|
    t.string   "name",                    null: false
    t.string   "iso_alpha2",              null: false
    t.string   "iso_alpha3",              null: false
    t.string   "postal_address_template", null: false
    t.datetime "created_at",              null: false
    t.datetime "updated_at",              null: false
  end

  add_index "countries", ["iso_alpha2"], name: "index_countries_on_iso_alpha2", unique: true, using: :btree
  add_index "countries", ["iso_alpha3"], name: "index_countries_on_iso_alpha3", unique: true, using: :btree
  add_index "countries", ["name"], name: "index_countries_on_name", unique: true, using: :btree

  create_table "image_files", id: :bigserial, force: :cascade do |t|
    t.integer  "site_id",        limit: 8,                 null: false
    t.integer  "image_id",       limit: 8,                 null: false
    t.string   "width",                                    null: false
    t.string   "height",                                   null: false
    t.string   "x_dimension"
    t.boolean  "default_image",            default: false, null: false
    t.boolean  "original_image",           default: false, null: false
    t.hstore   "metadata"
    t.datetime "created_at",                               null: false
    t.datetime "updated_at",                               null: false
  end

  add_index "image_files", ["image_id"], name: "index_image_files_on_image_id", using: :btree
  add_index "image_files", ["site_id"], name: "index_image_files_on_site_id", using: :btree

  create_table "image_instances", id: :bigserial, force: :cascade do |t|
    t.integer  "site_id",        limit: 8, null: false
    t.integer  "image_id",       limit: 8, null: false
    t.integer  "imageable_id",   limit: 8, null: false
    t.string   "imageable_type",           null: false
    t.hstore   "metadata"
    t.datetime "created_at",               null: false
    t.datetime "updated_at",               null: false
    t.string   "name"
    t.string   "description"
    t.integer  "order",                    null: false
  end

  add_index "image_instances", ["image_id"], name: "index_image_instances_on_image_id", using: :btree
  add_index "image_instances", ["imageable_type", "imageable_id"], name: "index_image_instances_on_imageable_type_and_imageable_id", using: :btree
  add_index "image_instances", ["imageable_type"], name: "index_image_instances_on_imageable_type", using: :btree
  add_index "image_instances", ["site_id"], name: "index_image_instances_on_site_id", using: :btree

  create_table "images", id: :bigserial, force: :cascade do |t|
    t.integer  "site_id",       limit: 8,              null: false
    t.string   "description",                          null: false
    t.hstore   "metadata"
    t.text     "tags",                    default: [],              array: true
    t.datetime "created_at",                           null: false
    t.datetime "updated_at",                           null: false
    t.string   "name",                                 null: false
    t.string   "extension",                            null: false
    t.string   "internal_name",                        null: false
  end

  add_index "images", ["site_id", "internal_name"], name: "index_images_on_site_id_and_internal_name", unique: true, using: :btree
  add_index "images", ["site_id"], name: "index_images_on_site_id", using: :btree

  create_table "inventories", id: :bigserial, force: :cascade do |t|
    t.boolean  "tracked",                 default: false, null: false
    t.integer  "quantity",                default: 0
    t.boolean  "back_orders",             default: false, null: false
    t.datetime "replenish_eta"
    t.datetime "exhausted_on"
    t.hstore   "metadata"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "product_id",    limit: 8
    t.integer  "variant_id",    limit: 8
    t.integer  "site_id",       limit: 8,                 null: false
  end

  add_index "inventories", ["product_id"], name: "index_inventories_on_product_id", using: :btree
  add_index "inventories", ["site_id"], name: "index_inventories_on_site_id", using: :btree
  add_index "inventories", ["variant_id"], name: "index_inventories_on_variant_id", using: :btree

  create_table "line_item_taxes", id: :bigserial, force: :cascade do |t|
    t.integer  "site_id",          limit: 8,                                         null: false
    t.integer  "line_item_id",     limit: 8,                                         null: false
    t.integer  "tax_rate_id",      limit: 8,                                         null: false
    t.datetime "created_at",                                                         null: false
    t.datetime "updated_at",                                                         null: false
    t.string   "currency",                                           default: "USD", null: false
    t.integer  "tax_amount_cents",                                   default: 0,     null: false
    t.decimal  "used_tax_rate",              precision: 6, scale: 5, default: 0.0,   null: false
  end

  add_index "line_item_taxes", ["line_item_id"], name: "index_line_item_taxes_on_line_item_id", using: :btree
  add_index "line_item_taxes", ["site_id"], name: "index_line_item_taxes_on_site_id", using: :btree
  add_index "line_item_taxes", ["tax_rate_id"], name: "index_line_item_taxes_on_tax_rate_id", using: :btree

  create_table "line_items", id: :bigserial, force: :cascade do |t|
    t.string   "customisation"
    t.integer  "quantity",                                                  default: 0
    t.integer  "price_cents",                                               default: 0,     null: false
    t.integer  "total_cents",                                               default: 0,     null: false
    t.string   "currency",                                                  default: "USD", null: false
    t.integer  "site_id",                 limit: 8,                                         null: false
    t.integer  "order_id",                limit: 8,                                         null: false
    t.integer  "product_id",              limit: 8
    t.integer  "variant_id",              limit: 8
    t.hstore   "metadata"
    t.text     "tags",                                                      default: [],                 array: true
    t.datetime "created_at",                                                                null: false
    t.datetime "updated_at",                                                                null: false
    t.string   "type",                                                                      null: false
    t.integer  "weight",                                                    default: 0
    t.integer  "total_weight",                                              default: 0
    t.integer  "tax_cents",                                                 default: 0,     null: false
    t.integer  "subtotal_cents",                                            default: 0,     null: false
    t.decimal  "total_tax_rate",                    precision: 6, scale: 5, default: 0.0,   null: false
    t.integer  "shipping_rate_region_id", limit: 8
  end

  add_index "line_items", ["order_id"], name: "index_line_items_on_order_id", using: :btree
  add_index "line_items", ["product_id"], name: "index_line_items_on_product_id", using: :btree
  add_index "line_items", ["shipping_rate_region_id"], name: "index_line_items_on_shipping_rate_region_id", using: :btree
  add_index "line_items", ["site_id"], name: "index_line_items_on_site_id", using: :btree
  add_index "line_items", ["variant_id"], name: "index_line_items_on_variant_id", using: :btree

  create_table "order_taxes", id: :bigserial, force: :cascade do |t|
    t.integer  "site_id",          limit: 8,                 null: false
    t.integer  "order_id",         limit: 8,                 null: false
    t.integer  "tax_rate_id",      limit: 8,                 null: false
    t.integer  "tax_amount_cents",           default: 0,     null: false
    t.string   "currency",                   default: "USD", null: false
    t.decimal  "used_tax_rate",              default: 0.0,   null: false
    t.datetime "created_at",                                 null: false
    t.datetime "updated_at",                                 null: false
  end

  add_index "order_taxes", ["order_id"], name: "index_order_taxes_on_order_id", using: :btree
  add_index "order_taxes", ["site_id"], name: "index_order_taxes_on_site_id", using: :btree
  add_index "order_taxes", ["tax_rate_id"], name: "index_order_taxes_on_tax_rate_id", using: :btree

  create_table "orders", id: :bigserial, force: :cascade do |t|
    t.integer  "total_cents",                       default: 0,     null: false
    t.string   "currency",                          default: "USD", null: false
    t.hstore   "metadata",                                          null: false
    t.text     "tags",                              default: [],                 array: true
    t.integer  "site_id",                 limit: 8,                 null: false
    t.datetime "created_at",                                        null: false
    t.datetime "updated_at",                                        null: false
    t.integer  "subtotal_cents",                    default: 0,     null: false
    t.integer  "weight",                            default: 0,     null: false
    t.integer  "total_commodities_cents",           default: 0,     null: false
    t.integer  "total_shipping_cents",              default: 0,     null: false
    t.integer  "total_tax_cents",                   default: 0,     null: false
    t.string   "workflow_state",                                    null: false
    t.integer  "customer_address_id",     limit: 8
    t.integer  "delivery_address_id",     limit: 8
  end

  add_index "orders", ["site_id"], name: "index_orders_on_site_id", using: :btree

  create_table "preferences", id: :bigserial, force: :cascade do |t|
    t.integer  "site_id",                    limit: 8,                 null: false
    t.integer  "tax_basis",                            default: 0,     null: false
    t.boolean  "prices_include_tax",                   default: false, null: false
    t.hstore   "metadata"
    t.datetime "created_at",                                           null: false
    t.datetime "updated_at",                                           null: false
    t.boolean  "order_subtotal_include_tax",           default: true,  null: false
    t.hstore   "reserved_paths",                                       null: false
  end

  add_index "preferences", ["site_id"], name: "index_preferences_on_site_id", using: :btree

  create_table "prioritized_countries", id: :bigserial, force: :cascade do |t|
    t.integer  "site_id",    limit: 8, null: false
    t.integer  "country_id", limit: 8, null: false
    t.datetime "created_at",           null: false
    t.datetime "updated_at",           null: false
  end

  add_index "prioritized_countries", ["country_id"], name: "index_prioritized_countries_on_country_id", using: :btree
  add_index "prioritized_countries", ["site_id"], name: "index_prioritized_countries_on_site_id", using: :btree

  create_table "products", id: :bigserial, force: :cascade do |t|
    t.string   "name",                                      null: false
    t.string   "generated_slug",                            null: false
    t.string   "specified_slug"
    t.string   "gtin"
    t.string   "sku"
    t.integer  "price_cents",                               null: false
    t.string   "currency",                  default: "USD", null: false
    t.integer  "weight",                    default: 0,     null: false
    t.boolean  "active"
    t.datetime "not_before"
    t.datetime "not_after"
    t.json     "specifications"
    t.hstore   "metadata"
    t.text     "tags",                      default: [],                 array: true
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "site_id",         limit: 8,                 null: false
    t.integer  "tax_override_id", limit: 8
    t.boolean  "enabled",                   default: true,  null: false
    t.string   "description",                               null: false
    t.text     "markup",                                    null: false
    t.integer  "markup_format",             default: 0
  end

  add_index "products", ["site_id", "generated_slug"], name: "index_products_on_site_id_and_generated_slug", unique: true, using: :btree
  add_index "products", ["site_id", "name"], name: "index_products_on_site_id_and_name", unique: true, using: :btree
  add_index "products", ["site_id", "specified_slug"], name: "index_products_on_site_id_and_specified_slug", unique: true, using: :btree
  add_index "products", ["site_id"], name: "index_products_on_site_id", using: :btree
  add_index "products", ["tax_override_id"], name: "index_products_on_tax_override_id", using: :btree

  create_table "shipping_rate_regions", id: :bigserial, force: :cascade do |t|
    t.integer  "site_id",              limit: 8,                 null: false
    t.integer  "country_id",           limit: 8,                 null: false
    t.integer  "state_id",             limit: 8
    t.string   "postcode"
    t.string   "locality"
    t.integer  "shipping_rate_id",     limit: 8,                 null: false
    t.integer  "price_cents",                                    null: false
    t.string   "currency",                       default: "USD", null: false
    t.ltree    "geographic_hierarchy",                           null: false
    t.hstore   "metadata"
    t.datetime "created_at",                                     null: false
    t.datetime "updated_at",                                     null: false
    t.boolean  "enabled",                        default: true,  null: false
    t.integer  "tax_override_id",      limit: 8
  end

  add_index "shipping_rate_regions", ["country_id"], name: "index_shipping_rate_regions_on_country_id", using: :btree
  add_index "shipping_rate_regions", ["geographic_hierarchy"], name: "index_shipping_rate_regions_on_geographic_hierarchy", using: :gist
  add_index "shipping_rate_regions", ["shipping_rate_id"], name: "index_shipping_rate_regions_on_shipping_rate_id", using: :btree
  add_index "shipping_rate_regions", ["site_id"], name: "index_shipping_rate_regions_on_site_id", using: :btree
  add_index "shipping_rate_regions", ["state_id"], name: "index_shipping_rate_regions_on_state_id", using: :btree
  add_index "shipping_rate_regions", ["tax_override_id"], name: "index_shipping_rate_regions_on_tax_override_id", using: :btree

  create_table "shipping_rates", id: :bigserial, force: :cascade do |t|
    t.integer  "site_id",         limit: 8,                 null: false
    t.string   "name",                                      null: false
    t.string   "description",                               null: false
    t.integer  "min_weight"
    t.integer  "max_weight"
    t.integer  "min_price_cents"
    t.integer  "max_price_cents"
    t.string   "currency",                  default: "USD", null: false
    t.hstore   "metadata"
    t.datetime "created_at",                                null: false
    t.datetime "updated_at",                                null: false
    t.boolean  "enabled",                   default: true,  null: false
  end

  add_index "shipping_rates", ["site_id"], name: "index_shipping_rates_on_site_id", using: :btree

  create_table "shopping_bag_operations", id: :bigserial, force: :cascade do |t|
    t.integer  "shopping_bag_id", limit: 8, null: false
    t.integer  "product_id",      limit: 8
    t.integer  "variant_id",      limit: 8
    t.uuid     "item_uuid",                 null: false
    t.integer  "quantity",                  null: false
    t.hstore   "metadata"
    t.integer  "site_id",         limit: 8, null: false
    t.datetime "created_at",                null: false
  end

  add_index "shopping_bag_operations", ["shopping_bag_id"], name: "index_shopping_bag_operations_on_shopping_bag_id", using: :btree
  add_index "shopping_bag_operations", ["site_id"], name: "index_shopping_bag_operations_on_site_id", using: :btree

  create_table "shopping_bags", id: :bigserial, force: :cascade do |t|
    t.integer  "site_id",        limit: 8, null: false
    t.string   "workflow_state",           null: false
    t.datetime "created_at",               null: false
    t.datetime "updated_at",               null: false
  end

  add_index "shopping_bags", ["site_id"], name: "index_shopping_bags_on_site_id", using: :btree

  create_table "sites", id: :bigserial, force: :cascade do |t|
    t.string   "name",                                            null: false
    t.datetime "created_at",                                      null: false
    t.datetime "updated_at",                                      null: false
    t.string   "currency_iso_code",                               null: false
    t.hstore   "metadata"
    t.integer  "subscriber_address_id", limit: 8
    t.boolean  "enabled",                         default: false, null: false
  end

  create_table "states", id: :bigserial, force: :cascade do |t|
    t.integer  "country_id",    limit: 8, null: false
    t.string   "name",                    null: false
    t.string   "iso_code",                null: false
    t.string   "postal_format",           null: false
    t.datetime "created_at",              null: false
    t.datetime "updated_at",              null: false
  end

  add_index "states", ["country_id"], name: "index_states_on_country_id", using: :btree
  add_index "states", ["iso_code"], name: "index_states_on_iso_code", unique: true, using: :btree

  create_table "tax_categories", id: :bigserial, force: :cascade do |t|
    t.integer  "site_id",                      limit: 8, null: false
    t.integer  "site_primary_tax_category_id", limit: 8
    t.string   "name",                                   null: false
    t.hstore   "metadata"
    t.datetime "created_at",                             null: false
    t.datetime "updated_at",                             null: false
  end

  add_index "tax_categories", ["site_id"], name: "index_tax_categories_on_site_id", using: :btree
  add_index "tax_categories", ["site_primary_tax_category_id"], name: "index_tax_categories_on_site_primary_tax_category_id", using: :btree

  create_table "tax_rates", id: :bigserial, force: :cascade do |t|
    t.decimal  "rate",                           precision: 6, scale: 5,                null: false
    t.string   "name",                                                                  null: false
    t.string   "description",                                                           null: false
    t.string   "invoice_note"
    t.integer  "site_id",              limit: 8,                                        null: false
    t.integer  "country_id",           limit: 8,                                        null: false
    t.string   "postcode"
    t.string   "locality"
    t.boolean  "shipping"
    t.integer  "priority",                                                              null: false
    t.ltree    "geographic_hierarchy",                                                  null: false
    t.hstore   "metadata"
    t.datetime "created_at",                                                            null: false
    t.datetime "updated_at",                                                            null: false
    t.integer  "tax_category_id",      limit: 8,                                        null: false
    t.integer  "state_id",             limit: 8
    t.boolean  "enabled",                                                default: true, null: false
  end

  add_index "tax_rates", ["country_id"], name: "index_tax_rates_on_country_id", using: :btree
  add_index "tax_rates", ["geographic_hierarchy"], name: "index_tax_rates_on_geographic_hierarchy", using: :gist
  add_index "tax_rates", ["site_id"], name: "index_tax_rates_on_site_id", using: :btree
  add_index "tax_rates", ["state_id"], name: "index_tax_rates_on_state_id", using: :btree
  add_index "tax_rates", ["tax_category_id"], name: "index_tax_rates_on_tax_category_id", using: :btree

  create_table "tenants", id: :bigserial, force: :cascade do |t|
    t.integer  "site_id",    limit: 8, null: false
    t.string   "identifier",           null: false
    t.datetime "created_at",           null: false
    t.datetime "updated_at",           null: false
  end

  add_index "tenants", ["identifier"], name: "index_tenants_on_identifier", using: :btree
  add_index "tenants", ["site_id"], name: "index_tenants_on_site_id", using: :btree

  create_table "traits", id: :bigserial, force: :cascade do |t|
    t.string   "name",                                    null: false
    t.string   "display_name",                            null: false
    t.text     "description"
    t.hstore   "metadata"
    t.text     "default_values",           default: [],                array: true
    t.text     "tags",                     default: [],                array: true
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "site_id",        limit: 8,                null: false
    t.boolean  "enabled",                  default: true, null: false
  end

  add_index "traits", ["site_id"], name: "index_traits_on_site_id", using: :btree

  create_table "variants", id: :bigserial, force: :cascade do |t|
    t.integer  "product_id",         limit: 8,                 null: false
    t.string   "gtin"
    t.string   "sku"
    t.integer  "varied_price_cents"
    t.string   "currency",                     default: "USD", null: false
    t.integer  "weight"
    t.json     "specifications"
    t.hstore   "metadata"
    t.text     "tags",                         default: [],                 array: true
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "site_id",            limit: 8,                 null: false
    t.boolean  "enabled",                      default: true,  null: false
  end

  add_index "variants", ["product_id"], name: "index_variants_on_product_id", using: :btree
  add_index "variants", ["site_id"], name: "index_variants_on_site_id", using: :btree

  create_table "variation_instances", id: :bigserial, force: :cascade do |t|
    t.integer  "variation_id",       limit: 8, null: false
    t.integer  "variant_id",         limit: 8, null: false
    t.hstore   "metadata"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "site_id",            limit: 8, null: false
    t.integer  "variation_value_id", limit: 8, null: false
  end

  add_index "variation_instances", ["site_id"], name: "index_variation_instances_on_site_id", using: :btree
  add_index "variation_instances", ["variant_id"], name: "index_variation_instances_on_variant_id", using: :btree
  add_index "variation_instances", ["variation_id"], name: "index_variation_instances_on_variation_id", using: :btree
  add_index "variation_instances", ["variation_value_id"], name: "index_variation_instances_on_variation_value_id", using: :btree

  create_table "variation_values", id: :bigserial, force: :cascade do |t|
    t.integer  "site_id",      limit: 8, null: false
    t.integer  "variation_id", limit: 8, null: false
    t.integer  "order",                  null: false
    t.datetime "created_at",             null: false
    t.datetime "updated_at",             null: false
    t.string   "name",                   null: false
    t.string   "description"
  end

  add_index "variation_values", ["site_id"], name: "index_variation_values_on_site_id", using: :btree
  add_index "variation_values", ["variation_id"], name: "index_variation_values_on_variation_id", using: :btree

  create_table "variations", id: :bigserial, force: :cascade do |t|
    t.integer  "product_id", limit: 8,             null: false
    t.integer  "trait_id",   limit: 8,             null: false
    t.integer  "order",                            null: false
    t.hstore   "metadata"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "site_id",    limit: 8,             null: false
    t.integer  "render_as",            default: 0, null: false
  end

  add_index "variations", ["product_id", "order"], name: "index_variations_on_product_id_and_order", unique: true, using: :btree
  add_index "variations", ["product_id"], name: "index_variations_on_product_id", using: :btree
  add_index "variations", ["site_id"], name: "index_variations_on_site_id", using: :btree
  add_index "variations", ["trait_id"], name: "index_variations_on_trait_id", using: :btree

  create_table "version_associations", id: :bigserial, force: :cascade do |t|
    t.integer "version_id"
    t.string  "foreign_key_name", null: false
    t.integer "foreign_key_id"
  end

  add_index "version_associations", ["foreign_key_name", "foreign_key_id"], name: "index_version_associations_on_foreign_key", using: :btree
  add_index "version_associations", ["version_id"], name: "index_version_associations_on_version_id", using: :btree

  create_table "versions", id: :bigserial, force: :cascade do |t|
    t.string   "item_type",                null: false
    t.integer  "item_id",        limit: 8, null: false
    t.string   "event",                    null: false
    t.string   "whodunnit"
    t.text     "object"
    t.integer  "transaction_id", limit: 8
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "versions", ["item_type", "item_id", "transaction_id"], name: "index_versions_on_item_type_and_item_id_and_transaction_id", using: :btree

  create_table "whitelisted_countries", id: :bigserial, force: :cascade do |t|
    t.integer  "site_id",    limit: 8, null: false
    t.integer  "country_id", limit: 8, null: false
    t.datetime "created_at",           null: false
    t.datetime "updated_at",           null: false
  end

  add_index "whitelisted_countries", ["country_id"], name: "index_whitelisted_countries_on_country_id", using: :btree
  add_index "whitelisted_countries", ["site_id"], name: "index_whitelisted_countries_on_site_id", using: :btree

  add_foreign_key "addresses", "countries", on_delete: :restrict
  add_foreign_key "addresses", "sites", on_delete: :cascade
  add_foreign_key "addresses", "states", on_delete: :restrict
  add_foreign_key "blacklisted_countries", "countries"
  add_foreign_key "blacklisted_countries", "sites"
  add_foreign_key "categories", "categories", column: "parent_category_id", on_delete: :cascade
  add_foreign_key "categories", "sites", on_delete: :cascade
  add_foreign_key "category_members", "categories", on_delete: :cascade
  add_foreign_key "category_members", "products", on_delete: :cascade
  add_foreign_key "category_members", "sites", on_delete: :cascade
  add_foreign_key "image_files", "images", on_delete: :cascade
  add_foreign_key "image_files", "sites", on_delete: :cascade
  add_foreign_key "image_instances", "images", on_delete: :restrict
  add_foreign_key "image_instances", "sites", on_delete: :cascade
  add_foreign_key "images", "sites", on_delete: :cascade
  add_foreign_key "inventories", "products", on_delete: :cascade
  add_foreign_key "inventories", "sites", on_delete: :cascade
  add_foreign_key "inventories", "variants", on_delete: :cascade
  add_foreign_key "line_item_taxes", "line_items", on_delete: :cascade
  add_foreign_key "line_item_taxes", "sites", on_delete: :cascade
  add_foreign_key "line_item_taxes", "tax_rates", on_delete: :restrict
  add_foreign_key "line_items", "orders", on_delete: :cascade
  add_foreign_key "line_items", "products", on_delete: :restrict
  add_foreign_key "line_items", "shipping_rate_regions", on_delete: :restrict
  add_foreign_key "line_items", "sites", on_delete: :cascade
  add_foreign_key "line_items", "variants", on_delete: :restrict
  add_foreign_key "order_taxes", "orders", on_delete: :cascade
  add_foreign_key "order_taxes", "sites", on_delete: :cascade
  add_foreign_key "order_taxes", "tax_rates", on_delete: :restrict
  add_foreign_key "orders", "addresses", column: "customer_address_id", on_delete: :restrict
  add_foreign_key "orders", "addresses", column: "delivery_address_id", on_delete: :restrict
  add_foreign_key "orders", "sites", on_delete: :cascade
  add_foreign_key "preferences", "sites", on_delete: :cascade
  add_foreign_key "prioritized_countries", "countries"
  add_foreign_key "prioritized_countries", "sites"
  add_foreign_key "products", "sites", on_delete: :cascade
  add_foreign_key "products", "tax_categories", column: "tax_override_id", on_delete: :restrict
  add_foreign_key "shipping_rate_regions", "countries"
  add_foreign_key "shipping_rate_regions", "shipping_rates"
  add_foreign_key "shipping_rate_regions", "sites"
  add_foreign_key "shipping_rate_regions", "states"
  add_foreign_key "shipping_rate_regions", "tax_categories", column: "tax_override_id", on_delete: :restrict
  add_foreign_key "shipping_rates", "sites"
  add_foreign_key "shopping_bag_operations", "products", on_delete: :restrict
  add_foreign_key "shopping_bag_operations", "shopping_bags", on_delete: :cascade
  add_foreign_key "shopping_bag_operations", "sites", on_delete: :cascade
  add_foreign_key "shopping_bag_operations", "variants", on_delete: :restrict
  add_foreign_key "shopping_bags", "sites", on_delete: :cascade
  add_foreign_key "sites", "addresses", column: "subscriber_address_id", on_delete: :restrict
  add_foreign_key "states", "countries", on_delete: :cascade
  add_foreign_key "tax_categories", "sites", column: "site_primary_tax_category_id", on_delete: :cascade
  add_foreign_key "tax_categories", "sites", on_delete: :cascade
  add_foreign_key "tax_rates", "countries", on_delete: :restrict
  add_foreign_key "tax_rates", "sites", on_delete: :cascade
  add_foreign_key "tax_rates", "states", on_delete: :restrict
  add_foreign_key "tax_rates", "tax_categories", on_delete: :cascade
  add_foreign_key "tenants", "sites", on_delete: :cascade
  add_foreign_key "traits", "sites", on_delete: :cascade
  add_foreign_key "variants", "products", on_delete: :cascade
  add_foreign_key "variants", "sites", on_delete: :cascade
  add_foreign_key "variation_instances", "sites", on_delete: :cascade
  add_foreign_key "variation_instances", "variants", on_delete: :cascade
  add_foreign_key "variation_instances", "variation_values", on_delete: :restrict
  add_foreign_key "variation_instances", "variations", on_delete: :cascade
  add_foreign_key "variation_values", "sites", on_delete: :cascade
  add_foreign_key "variation_values", "variations", on_delete: :cascade
  add_foreign_key "variations", "products", on_delete: :cascade
  add_foreign_key "variations", "sites", on_delete: :cascade
  add_foreign_key "variations", "traits", on_delete: :cascade
  add_foreign_key "whitelisted_countries", "countries"
  add_foreign_key "whitelisted_countries", "sites"
end
