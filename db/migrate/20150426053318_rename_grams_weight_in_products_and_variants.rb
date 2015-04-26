class RenameGramsWeightInProductsAndVariants < ActiveRecord::Migration
  def change
    rename_column :products, :grams, :weight
    rename_column :variants, :grams, :weight
  end
end
