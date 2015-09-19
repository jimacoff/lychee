require 'rails_helper'

RSpec.feature 'shopping carts', site_scoped: true do
  given!(:product) { create(:product) }
  given!(:variant) { create(:variant) }

  background do
    visit '/shopping-cart'
  end

  scenario 'adding an item to the cart' do
    fill_in 'Product ID', with: product.id
    fill_in 'Quantity', with: '100'
    click_button 'Add to Cart'

    within('#cart tr', text: product.description) do
      expect(find('td input')['value']).to eq('100')
    end
  end
end
