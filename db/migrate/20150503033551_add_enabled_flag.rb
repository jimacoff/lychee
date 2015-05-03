class AddEnabledFlag < ActiveRecord::Migration
  def change
    add_column :tax_rates, :enabled, :boolean, null: false, default: true
    add_column :shipping_rates, :enabled, :boolean, null: false, default: true
    add_column :shipping_rate_regions, :enabled, :boolean, null: false, default: true
    add_column :products, :enabled, :boolean, null: false, default: true
    add_column :variants, :enabled, :boolean, null: false, default: true
    add_column :categories, :enabled, :boolean, null: false, default: true
    add_column :traits, :enabled, :boolean, null: false, default: true
  end
end
