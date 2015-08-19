class UniqueIsoCodeForStates < ActiveRecord::Migration
  def change
    add_index :states, :iso_code, unique: true
  end
end
