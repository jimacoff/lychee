class AddForeignKeys < ActiveRecord::Migration
  def change
    with_options on_delete: :restrict do |t|
      # Not site specific
      t.add_foreign_key 'addresses', 'countries'
      t.add_foreign_key 'tax_rates', 'countries'

      # If products/variants are tied to an order they can't be deleted
      t.add_foreign_key 'order_lines', 'products'
      t.add_foreign_key 'order_lines', 'variants'
    end

    with_options on_delete: :cascade do |t|
      # This data is all scoped within a single site.
      #
      # For something like an order we'd never want to actually
      # provide the functionality to delete.
      t.add_foreign_key 'addresses', 'orders', column: 'order_customer_address_id'
      t.add_foreign_key 'addresses', 'orders', column: 'order_delivery_address_id'
      t.add_foreign_key 'addresses', 'sites'
      t.add_foreign_key 'addresses', 'sites', column: 'site_subscriber_address_id'
      t.add_foreign_key 'categories', 'sites'
      t.add_foreign_key 'categories', 'categories', column: 'parent_category_id'
      t.add_foreign_key 'category_members', 'sites'
      t.add_foreign_key 'category_members', 'categories'
      t.add_foreign_key 'category_members', 'products'
      t.add_foreign_key 'category_members', 'variants'
      t.add_foreign_key 'inventories', 'products'
      t.add_foreign_key 'inventories', 'sites'
      t.add_foreign_key 'inventories', 'variants'
      t.add_foreign_key 'order_lines', 'orders'
      t.add_foreign_key 'order_lines', 'sites'
      t.add_foreign_key 'orders', 'sites'
      t.add_foreign_key 'products', 'sites'
      t.add_foreign_key 'tax_rates', 'sites'
      t.add_foreign_key 'tax_rates', 'tax_categories'
      t.add_foreign_key 'traits', 'sites'
      t.add_foreign_key 'variants', 'products'
      t.add_foreign_key 'variants', 'sites'
      t.add_foreign_key 'variation_instances', 'sites'
      t.add_foreign_key 'variation_instances', 'variants'
      t.add_foreign_key 'variation_instances', 'variations'
      t.add_foreign_key 'variations', 'products'
      t.add_foreign_key 'variations', 'sites'
      t.add_foreign_key 'variations', 'traits'
    end
  end
end
