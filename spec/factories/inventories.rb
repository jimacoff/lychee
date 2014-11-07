FactoryGirl.define do
  factory :tracked_inventory, class: 'Inventory' do
    tracked true
    quantity 10
    back_orders false
  end
end
