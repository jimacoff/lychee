class AddSiteToExistingModels < ActiveRecord::Migration
  TABLES = [:categories, :category_members, :inventories, :products, :traits,
            :variants, :variations, :variation_instances]

  def change
    TABLES.each do |table|
      change_table table do |t|
        t.belongs_to :site, null: false, index: true
      end
    end
  end

end
