class AddNameToVariant < ActiveRecord::Migration
  def change
    add_column :variants, :name, :string
  end
end
