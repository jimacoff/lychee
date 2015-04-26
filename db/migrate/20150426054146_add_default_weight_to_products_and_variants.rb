class AddDefaultWeightToProductsAndVariants < ActiveRecord::Migration
  def change
    change_column :products, :weight, :integer, allow_nil: false, default: 0
    change_column :variants, :weight, :integer, allow_nil: true
  end
end
