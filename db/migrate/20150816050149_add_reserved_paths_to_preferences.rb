class AddReservedPathsToPreferences < ActiveRecord::Migration
  def change
    add_column :preferences, :reserved_paths, :hstore, null: false
  end
end
