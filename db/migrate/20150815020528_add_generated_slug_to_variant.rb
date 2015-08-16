class AddGeneratedSlugToVariant < ActiveRecord::Migration
  def change
    add_column :variants, :generated_slug, :string
  end
end
