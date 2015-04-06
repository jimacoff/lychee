class AddSiteKeysToAddress < ActiveRecord::Migration
  def change
    add_reference :addresses, :site_subscriber_address, index: true
    add_reference :addresses, :site_distribution_address, index: true
  end
end
