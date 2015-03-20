FactoryGirl.define do
  factory :tracked_inventory, class: 'Inventory' do
    tracked true
    quantity 10
  end

  factory :tracked_product_inventory, class: 'Inventory' do
    tracked true
    quantity 10
    product
  end

  factory :tracked_variant_inventory, class: 'Inventory' do
    tracked true
    quantity 10
    variant
  end

  factory :untracked_inventory, class: 'Inventory' do
    tracked false
  end
end
