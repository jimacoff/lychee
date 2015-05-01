class AddLtreeGistIndexes < ActiveRecord::Migration
  def change
    add_index :tax_rates, :hierarchy, using: :gist
    add_index :shipping_rate_regions, :hierarchy, using: :gist
  end
end
