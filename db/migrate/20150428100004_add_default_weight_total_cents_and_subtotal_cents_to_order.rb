class AddDefaultWeightTotalCentsAndSubtotalCentsToOrder < ActiveRecord::Migration
  def change
    change_column :orders, :weight, :integer,
                  allow_nil: false, default: 0

    change_column :orders, :subtotal_cents, :integer,
                  allow_nil: false, default: 0

    change_column :orders, :total_cents, :integer,
                  allow_nil: false, default: 0
  end
end
