class AddEnabledFlagToSite < ActiveRecord::Migration
  def change
    add_column :sites, :enabled, :boolean, default: false, null: false
  end
end
