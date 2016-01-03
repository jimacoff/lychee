class AddEmailPreferences < ActiveRecord::Migration
  def change
    add_column :preferences, :hostname, :string, null: false
    add_column :preferences, :protocol, :string, null: false

    add_column :preferences, :email_from_address, :string, null: false
    add_column :preferences, :email_from_name, :string, null: false
    add_column :preferences, :email_subaccount_identifier, :string, null: false
    add_column :preferences, :email_api_key, :string, null: false
  end
end
