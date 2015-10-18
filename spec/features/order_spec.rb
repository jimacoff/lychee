require 'rails_helper'

RSpec.feature 'Ordering', site_scoped: true do
  given!(:product) { create(:product) }

  background do
    visit '/test-store/products'

    within('form', text: product.name) do
      click_button 'Add to Bag'
    end

    expect(current_path).to eq(shopping_bag_path)
    click_button 'Checkout'
  end

  it 'shows stuff' do
    expect(current_path).to eq(order_path)
    expect(page).to have_css('tr', text: product.name)
  end
end
