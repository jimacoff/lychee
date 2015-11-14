require 'rails_helper'

RSpec.feature 'Shopping', site_scoped: true do
  def bag_path
    expect(current_path).to eq('/shop/bag')
  end

  def flash
    expect(page).to have_css('#bag-flash')
  end

  def no_flash
    expect(page).not_to have_css('#bag-flash')
  end

  def shows_each_item(count)
    expect(page).to have_css('#bag #bag-items .bag-item', count: count)
  end

  # rubocop:disable Metrics/AbcSize
  def item_common_markup(item_count:)
    expect(page).to have_css('.name', text: product.name)
    expect(page).to have_field('operations[][quantity]', with: item_count)
    expect(page).to have_css('.description', text: product.description)
    expect(page).to have_css('.price', text: price)
    expect(page).to have_css('.total', text: total)
  end
  # rubocop:enable Metrics/AbcSize

  def item_metadata_textarea(with:)
    within('.metadata') do
      expect(page)
        .to have_field('operations[][metadata[message]]', type: 'textarea',
                                                          with: with)
    end
  end

  def product_common_markup(item_count:)
    item_common_markup(item_count: item_count)
    expect(page).not_to have_css('.variation-choices')
  end

  def variant_common_markup(item_count:)
    item_common_markup(item_count: item_count)
    expect(page).to have_css('.variation-choices')
  end

  def bag_summary(item_count:, subtotal:)
    within('#bag #bag-footer #bag-summary #bag-summary-calculated') do
      expect(page)
        .to have_css('#bag-summary-calculated-item-count', text: item_count)
      expect(page)
        .to have_css('#bag-summary-calculated-subtotal', text: subtotal)
    end
  end

  # rubocop:disable Metrics/AbcSize
  def bag_actions
    href = Site.current.preferences.reserved_uri_path('categories')
    within('#bag #bag-actions') do
      expect(page).to have_css('#continue-shopping', text: 'Continue Shopping')
      expect(page).to have_link('Continue Shopping', href: href)
      expect(page).to have_css('#checkout-securely', text: 'Securely Checkout')
    end
  end
  # rubocop:enable Metrics/AbcSize

  def bag_empty
    expect(page).to have_css('#bag-empty')
    expect(page).to have_css('#bag-start-shopping')
  end

  def add_product(item)
    visit '/test-store/products'

    within('form', text: item.name) do
      click_button 'Add to Bag'
    end
  end

  def add_variant(item)
    visit '/test-store/products'

    within('form', text: item.name) do
      # Per factory variation values
      choose(%w(small medium large).sample)
      choose(%w(blue red green).sample)
      click_button 'Add to Bag'
    end
  end

  shared_context 'checkout securely' do
    scenario 'checkout securely' do
      within('#bag #bag-actions') do
        click_button 'Securely Checkout'
      end

      expect(current_path).to eq('/shop/checkout')
    end
  end

  shared_context 'a single item' do
    context 'with no submissible metadata' do
      let!(:product) { product_without_metadata }

      before { add_item }

      context 'an empty bag' do
        scenario 'add an item to the bag' do
          bag_path
          shows_each_item(1)

          within('#bag #bag-items .bag-item') do
            common_markup(item_count: 1)
            expect(page).not_to have_css('.metadata')
          end

          no_flash
          bag_summary(item_count: quantity, subtotal: total)
          bag_actions
        end

        include_examples 'checkout securely'
        it 'has #bag-summary-notice from Site preferences'
        it 'has #bag-empty and #bag-start-shopping from Site preferences'
      end

      context 'with a single item in the bag' do
        let(:quantity) { rand(2..20) }

        scenario 'update the quantity' do
          within('#bag #bag-items .bag-item') do
            fill_in 'operations[][quantity]', with: quantity
            click_button 'Save Changes'

            bag_path
            common_markup(item_count: quantity)
            expect(page).not_to have_css('.metadata')
          end

          flash
          bag_summary(item_count: quantity, subtotal: total)
          bag_actions
        end

        scenario 'remove the item' do
          within('#bag #bag-items .bag-item') do
            click_button 'Remove Item'
          end

          bag_path
          bag_empty
        end

        include_examples 'checkout securely'
        it 'has #bag-summary-notice from Site preferences'
        it 'has #bag-empty and #bag-start-shopping from Site preferences'
      end
    end

    context 'with submissible metadata as textarea' do
      let!(:product) { product_with_metadata }

      before { add_item }

      context 'an empty bag' do
        scenario 'add an item to the bag' do
          bag_path
          shows_each_item(1)

          within('#bag #bag-items .bag-item') do
            common_markup(item_count: 1)
            item_metadata_textarea(with: '')
          end

          no_flash
          bag_summary(item_count: quantity, subtotal: total)
          bag_actions
        end

        include_examples 'checkout securely'
        it 'has #bag-summary-notice from Site preferences'
        it 'has #bag-empty and #bag-start-shopping from Site preferences'
      end

      context 'with a single item in the bag' do
        context 'quantity changes' do
          let(:quantity) { rand(2..20) }
          scenario 'updates the quantity' do
            within('#bag #bag-items .bag-item') do
              fill_in 'operations[][quantity]', with: quantity
              click_button 'Save Changes'

              bag_path
              common_markup(item_count: quantity)
              item_metadata_textarea(with: '')
            end

            flash
            bag_summary(item_count: quantity, subtotal: total)
            bag_actions
          end
        end

        context 'metadata changes' do
          let(:message) { Faker::Lorem.paragraph }
          scenario 'update the metadata message' do
            within('#bag #bag-items .bag-item') do
              fill_in 'operations[][metadata[message]]', with: message
              click_button 'Save Changes'

              bag_path
              common_markup(item_count: 1)
              item_metadata_textarea(with: message)
            end

            flash
            bag_summary(item_count: quantity, subtotal: total)
            bag_actions
          end
        end

        context 'quantity and metadata changes' do
          let(:quantity) { rand(2..20) }
          let(:message) { Faker::Lorem.paragraph }
          scenario 'update quantity and the metadata message' do
            within('#bag #bag-items .bag-item') do
              fill_in 'operations[][quantity]', with: quantity
              fill_in 'operations[][metadata[message]]', with: message
              click_button 'Save Changes'

              bag_path
              common_markup(item_count: quantity)
              item_metadata_textarea(with: message)
            end

            flash
            bag_summary(item_count: quantity, subtotal: total)
            bag_actions
          end
        end

        scenario 'remove the item' do
          within('#bag #bag-items .bag-item') do
            click_button 'Remove Item'
          end

          bag_path
          no_flash
          shows_each_item(0)
          bag_empty
        end

        include_examples 'checkout securely'
        it 'has #bag-summary-notice from Site preferences'
        it 'has #bag-empty and #bag-start-shopping from Site preferences'
      end
    end
  end

  context 'single item in the bag' do
    let(:quantity) { 1 }
    let(:price) { product.price }
    let(:total) { product.price * quantity }

    context 'a single product without variants' do
      include_examples 'a single item' do
        let(:add_item) { add_product(product) }
        let(:product_without_metadata) do
          create(:standalone_product)
        end
        let(:product_with_metadata) do
          create(:standalone_product, :with_message_metadata)
        end

        # rubocop:disable Style/Alias
        before { alias :common_markup :product_common_markup }
        # rubocop:enable Style/Alias
      end
    end

    context 'a single product with variants' do
      include_examples 'a single item' do
        let(:add_item) { add_variant(product) }
        let(:product_without_metadata) do
          create(:product, :with_variants)
        end
        let(:product_with_metadata) do
          create(:product, :with_variants, :with_message_metadata)
        end

        # rubocop:disable Style/Alias
        before { alias :common_markup :variant_common_markup }
        # rubocop:enable Style/Alias
      end
    end
  end

  context 'multiple items in the bag' do
    let(:products) { [] }
    let(:product_count) { rand(1..10) }
    let(:variant_count) { rand(1..10) }
    let(:item_count) { product_count + variant_count }
    let(:subtotal) { products.map(&:price).sum }

    before do
      (0...product_count).each do
        product = create :standalone_product
        products << product
        add_product(product)
      end
      (0...variant_count).each do
        product = create :product, :with_variants
        products << product
        add_variant(product)
      end
    end

    context 'after adding all items' do
      scenario 'bag is populated correctly' do
        bag_path
        no_flash
        shows_each_item(item_count)
        bag_summary(item_count: item_count, subtotal: subtotal)
        bag_actions
      end
    end

    context 'modifying an item' do
      let(:target) { rand(0...item_count) }
      let(:quantity) { rand(2..20) }
      let(:new_item_count) { item_count - 1 + quantity }
      let(:new_subtotal) do
        subtotal - products[target].price + products[target].price * quantity
      end

      scenario 'can modify an item' do
        within all('#bag #bag-items .bag-item')[target] do
          fill_in 'operations[][quantity]', with: quantity
          click_button 'Save Changes'
        end

        bag_path
        flash
        bag_summary(item_count: new_item_count, subtotal: new_subtotal)
        bag_actions
      end
    end

    include_examples 'checkout securely'
  end
end
