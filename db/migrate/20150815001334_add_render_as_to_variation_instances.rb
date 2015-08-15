class AddRenderAsToVariationInstances < ActiveRecord::Migration
  def change
    add_column :variation_instances, :render_as, :integer,
                                     default: 0, null: false
  end
end
