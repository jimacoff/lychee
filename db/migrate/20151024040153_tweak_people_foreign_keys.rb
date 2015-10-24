class TweakPeopleForeignKeys < ActiveRecord::Migration
  def change
    remove_foreign_key :people, :sites
    remove_foreign_key :orders, column: :customer_id
    remove_foreign_key :orders, column: :recipient_id

    add_foreign_key :people, :sites, on_delete: :cascade
    add_foreign_key :orders, :people, column: :customer_id,
                                         on_delete: :restrict
    add_foreign_key :orders, :people, column: :recipient_id,
                                         on_delete: :restrict
  end
end
