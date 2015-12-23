class AddBraintreeDataToPreferences < ActiveRecord::Migration
  def change
    add_column :preferences, :braintree_configured, :boolean, default: false
    add_column :preferences, :braintree_environment, :integer, null: false,
                                                               default: 0
    add_column :preferences, :braintree_merchant_id, :string, null: true
    add_column :preferences, :braintree_public_key, :string, null: true
    add_column :preferences, :braintree_private_key, :string, null: true
  end
end
