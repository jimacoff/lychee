class AddSiteIdToPeople < ActiveRecord::Migration
  def change
    change_table :people do |t|
      t.references :site, null: false, index: true
    end

    add_foreign_key :people, :sites, on_delete: :restrict
  end
end
