class EnableLTree < ActiveRecord::Migration
  def up
    enable_extension 'ltree'
  end

  def down
    disable_extension 'ltree'
  end
end
