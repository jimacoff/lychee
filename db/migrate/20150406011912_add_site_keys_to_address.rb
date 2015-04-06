class AddSiteKeysToAddress < ActiveRecord::Migration
  def change
    add_reference :addresses, :site_subscriber_address, index: true
  end
end
