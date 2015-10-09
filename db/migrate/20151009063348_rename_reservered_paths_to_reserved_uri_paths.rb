class RenameReserveredPathsToReservedUriPaths < ActiveRecord::Migration
  def change
    rename_column :preferences, :reserved_paths, :reserved_uri_paths
  end
end
