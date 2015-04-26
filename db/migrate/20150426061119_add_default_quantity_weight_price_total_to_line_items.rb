class AddDefaultQuantityWeightPriceTotalToLineItems < ActiveRecord::Migration
  def change
    change_column :line_items, :price_cents, :integer,
                  allow_nil: false, default: 0

    change_column :line_items, :total_cents, :integer,
                  allow_nil: false, default: 0

    change_column :line_items, :quantity, :integer,
                  allow_nil: false, default: 0

    change_column :line_items, :weight, :integer,
                  allow_nil: true, default: 0
  end
end
