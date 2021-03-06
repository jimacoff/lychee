require 'rails_helper'

RSpec.feature 'Ordering', site_scoped: true do
  before do
    allow_any_instance_of(ShoppingBagsController).to receive(:site_path)
      .and_return('-1')
    allow_any_instance_of(OrdersController).to receive(:site_path)
      .and_return('-1')
  end

  given!(:product) { create(:product) }

  background do
    visit '/test-store/products'

    within('form', text: product.name) do
      click_button 'Add to Bag'
    end

    expect(current_path).to eq(shopping_bag_path)
    click_button 'Securely Checkout'
  end

  it 'shows stuff' do
    expect(current_path).to eq(order_path)
  end
end
