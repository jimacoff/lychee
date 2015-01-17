FactoryGirl.define do
  factory :tracked_inventory, class: 'Inventory' do
    tracked true
    quantity 10
  end

  factory :untracked_inventory, class: 'Inventory' do
    tracked false
  end
end
