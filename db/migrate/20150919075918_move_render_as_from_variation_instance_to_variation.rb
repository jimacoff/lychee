class MoveRenderAsFromVariationInstanceToVariation < ActiveRecord::Migration
  def change
    add_column :variations, :render_as, :integer, default: 0, null: false
    remove_column :variation_instances, :render_as
  end
end
