class AddBagViewPreferences < ActiveRecord::Migration
  def change
    add_column :preferences, :bag_title, :string, null: false
    add_column :preferences, :bag_flash, :string, null: false
    add_column :preferences, :bag_summary_notice, :string, null: false
    add_column :preferences, :bag_action_continue_shopping, :string, null: false
    add_column :preferences, :bag_action_checkout, :string, null: false
    add_column :preferences, :bag_empty_notice, :string, null: false
    add_column :preferences, :bag_empty_start_shopping, :string, null: false
  end
end
