require 'rails_helper'

RSpec.feature 'Shopping', site_scoped: true do
  context 'buying a product' do
    given!(:product) { create(:product) }

    background do
      visit '/test-store/products'
    end

    scenario 'adds a product to the bag' do
      within('form', text: product.name) do
        click_button 'Add to Bag'
      end

      expect(current_path).to eq('/shop/bag')
      expect(page).to have_css('tr', text: product.name)
    end

    scenario 'updates the product quantity' do
      within('form', text: product.name) do
        click_button 'Add to Bag'
      end

      expect(current_path).to eq('/shop/bag')

      within('tr', text: product.name) do
        find('input').set('10')
      end

      click_button 'Update Bag'

      force_refresh

      within('tr', text: product.name) do
        expect(find('input').value).to eq('10')
      end
    end
  end

  context 'buying a variant' do
    pending 'adds a variant to the bag'
    pending 'updates the variant quantity'
  end
end
