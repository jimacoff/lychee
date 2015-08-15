class AddSpecifiedSlugToVariant < ActiveRecord::Migration
  def change
    add_column :variants, :specified_slug, :string
  end
end
