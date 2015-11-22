require 'rails_helper'

RSpec.feature 'Shopping', site_scoped: true do
  before do
    allow_any_instance_of(ShoppingBagsController).to receive(:site_path)
      .and_return('-1')
    allow_any_instance_of(OrdersController).to receive(:site_path)
      .and_return('-1')
  end

  def preferences
    Site.current.preferences
  end

  def bag_path
    expect(current_path).to eq('/shop/bag')
  end

  def bag_content_header
    expect(page).to have_css('#bag #bag-header h2', text: preferences.bag_title)
  end

  def flash
    expect(page).to have_css('#bag-flash', text: preferences.bag_flash)
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

  # rubocop:disable Metrics/AbcSize, Metrics/MethodLength
  def bag_summary(item_count:, subtotal:)
    within('#bag #bag-footer #bag-summary #bag-summary-calculated') do
      expect(page)
        .to have_css('#bag-summary-calculated-item-count', text: item_count)
      expect(page)
        .to have_css('#bag-summary-calculated-subtotal', text: subtotal)
    end

    within('#bag #bag-footer') do
      expect(page)
        .to have_css('#bag-summary-notice',
                     text: Site.current.preferences.bag_summary_notice)
    end
  end

  def bag_summary_extended(item_count:, subtotal:, shipping:, total:)
    bag_summary(item_count: item_count, subtotal: subtotal)
    within('#bag #bag-footer #bag-summary #bag-summary-calculated') do
      expect(page)
        .to have_css('#bag-summary-shipping', text: shipping)
      expect(page)
        .to have_css('#bag-summary-current-total', text: total)
    end

    return unless set_bag_shipping_notice

    within('#bag #bag-footer') do
      expect(page)
        .to have_css('#bag-shipping-notice p',
                     text: Site.current.preferences.bag_shipping_notice)
    end
  end

  def bag_summary_not_extended(item_count:, subtotal:)
    bag_summary(item_count: item_count, subtotal: subtotal)
    within('#bag #bag-footer #bag-summary #bag-summary-calculated') do
      expect(page).not_to have_css('#bag-summary-shipping')
      expect(page).not_to have_css('#bag-summary-current-total')
    end

    within('#bag #bag-footer') do
      expect(page).not_to have_css('#bag-shipping-notice')
    end
  end
  # rubocop:enable Metrics/AbcSize, Metrics/MethodLength

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
    expect(page).to have_css('#bag-empty p',
                             text: preferences.bag_empty_notice)
    expect(page).to have_link(Site.current.preferences.bag_empty_start_shopping,
                              href: preferences.reserved_uri_path('categories'))
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

  shared_context 'empty_bag' do
    scenario 'add an item to the bag' do
      bag_path
      bag_content_header
      shows_each_item(1)

      within('#bag #bag-items .bag-item') do
        common_markup(item_count: 1)
        if with_metadata
          item_metadata_textarea(with: '')
        else
          expect(page).not_to have_css('.metadata')
        end
      end

      no_flash
      summary
      bag_actions
    end
    include_examples 'checkout securely'
  end

  shared_context 'update_bag' do
    scenario 'update the quantity' do
      within('#bag #bag-items .bag-item') do
        fill_in 'operations[][quantity]', with: quantity
        if message.present?
          fill_in 'operations[][metadata[message]]', with: message
        end

        click_button 'Save Changes'

        bag_path
        common_markup(item_count: quantity)
        if with_metadata
          expect(page).to have_css('.metadata')
          item_metadata_textarea(with: message) if message.present?
        else
          expect(page).not_to have_css('.metadata')
        end
      end

      bag_content_header
      flash
      summary
      bag_actions
    end
  end

  shared_context 'a single item' do
    let(:sr) { Site.current.shipping_rates.first }
    let(:srr) { Site.current.shipping_rates.first.shipping_rate_regions.first }
    let(:set_shipping) { false }
    let(:message) { nil }

    before do
      if set_shipping
        Site.current.shipping_rates
          .create!(name: Faker::Lorem.word, description: Faker::Lorem.word,
                   use_as_bag_shipping: true, enabled: true)
        Site.current.shipping_rates.first.shipping_rate_regions
          .create!(country: Site.current.country, price: rand(1.0..99.99))

        if set_bag_shipping_notice
          Site.current.preferences
            .update(bag_shipping_notice: bag_shipping_notice)
        end
      end
    end

    context 'with no submissible metadata' do
      let(:with_metadata) { false }
      let!(:product) { product_without_metadata }
      before { add_item }

      context 'an empty bag' do
        context 'without shipping' do
          let(:summary) do
            bag_summary_not_extended(item_count: quantity, subtotal: subtotal)
          end
          include_examples 'empty_bag'
        end

        context 'with shipping' do
          let(:set_shipping) { true }
          let(:set_bag_shipping_notice) { false }
          let(:summary) do
            bag_summary_extended(item_count: quantity, subtotal: subtotal,
                                 shipping: srr.price,
                                 total: (subtotal + srr.price).to_s)
          end
          include_examples 'empty_bag'

          context 'with shipping notice' do
            let(:set_bag_shipping_notice) { true }
            let(:bag_shipping_notice) { Faker::Lorem.sentence }
            include_examples 'empty_bag'
          end
        end
      end

      context 'with a single item in the bag' do
        let(:quantity) { rand(2..20) }

        context 'without shipping' do
          let(:summary) do
            bag_summary_not_extended(item_count: quantity, subtotal: subtotal)
          end
          include_examples 'update_bag'
          include_examples 'checkout securely'
        end

        context 'with shipping' do
          let(:set_shipping) { true }
          let(:set_bag_shipping_notice) { false }
          let(:summary) do
            bag_summary_extended(item_count: quantity, subtotal: subtotal,
                                 shipping: srr.price,
                                 total: (subtotal + srr.price).to_s)
          end
          include_examples 'update_bag'

          context 'with shipping notice' do
            let(:set_bag_shipping_notice) { true }
            let(:bag_shipping_notice) { Faker::Lorem.sentence }
            include_examples 'update_bag'
            include_examples 'checkout securely'
          end
        end

        scenario 'remove the item' do
          within('#bag #bag-items .bag-item') do
            click_button 'Remove Item'
          end

          bag_path
          bag_empty
        end
      end
    end

    context 'with submissible metadata as textarea' do
      let(:with_metadata) { true }
      let!(:product) { product_with_metadata }

      before { add_item }

      context 'an empty bag' do
        context 'without shipping' do
          let(:summary) do
            bag_summary_not_extended(item_count: quantity, subtotal: subtotal)
          end
          include_examples 'empty_bag'
        end

        context 'with shipping' do
          let(:set_shipping) { true }
          let(:set_bag_shipping_notice) { false }
          let(:summary) do
            bag_summary_extended(item_count: quantity, subtotal: subtotal,
                                 shipping: srr.price,
                                 total: (subtotal + srr.price).to_s)
          end
          include_examples 'empty_bag'

          context 'with shipping notice' do
            let(:set_bag_shipping_notice) { true }
            let(:bag_shipping_notice) { Faker::Lorem.sentence }

            include_examples 'empty_bag'
          end
        end
      end

      context 'with a single item in the bag' do
        context 'quantity changes' do
          let(:quantity) { rand(2..20) }
          context 'without shipping' do
            let(:summary) do
              bag_summary_not_extended(item_count: quantity, subtotal: subtotal)
            end
            include_examples 'update_bag'
            include_examples 'checkout securely'
          end

          context 'with shipping' do
            let(:set_shipping) { true }
            let(:set_bag_shipping_notice) { false }
            let(:summary) do
              bag_summary_extended(item_count: quantity, subtotal: subtotal,
                                   shipping: srr.price,
                                   total: (subtotal + srr.price).to_s)
            end
            include_examples 'update_bag'

            context 'with shipping notice' do
              let(:set_bag_shipping_notice) { true }
              let(:bag_shipping_notice) { Faker::Lorem.sentence }
              include_examples 'update_bag'
              include_examples 'checkout securely'
            end
          end
        end

        context 'metadata changes' do
          let(:message) { Faker::Lorem.paragraph }
          context 'without shipping' do
            let(:summary) do
              bag_summary_not_extended(item_count: quantity, subtotal: subtotal)
            end
            include_examples 'update_bag'
            include_examples 'checkout securely'
          end

          context 'with shipping' do
            let(:set_shipping) { true }
            let(:set_bag_shipping_notice) { false }
            let(:summary) do
              bag_summary_extended(item_count: quantity, subtotal: subtotal,
                                   shipping: srr.price,
                                   total: (subtotal + srr.price).to_s)
            end
            include_examples 'update_bag'

            context 'with shipping notice' do
              let(:set_bag_shipping_notice) { true }
              let(:bag_shipping_notice) { Faker::Lorem.sentence }
              include_examples 'update_bag'
              include_examples 'checkout securely'
            end
          end
        end

        context 'quantity and metadata changes' do
          let(:quantity) { rand(2..20) }
          let(:message) { Faker::Lorem.paragraph }
          context 'without shipping' do
            let(:summary) do
              bag_summary_not_extended(item_count: quantity, subtotal: subtotal)
            end
            include_examples 'update_bag'
            include_examples 'checkout securely'
          end

          context 'with shipping' do
            let(:set_shipping) { true }
            let(:set_bag_shipping_notice) { false }
            let(:summary) do
              bag_summary_extended(item_count: quantity, subtotal: subtotal,
                                   shipping: srr.price,
                                   total: (subtotal + srr.price).to_s)
            end
            include_examples 'update_bag'

            context 'with shipping notice' do
              let(:set_bag_shipping_notice) { true }
              let(:bag_shipping_notice) { Faker::Lorem.sentence }
              include_examples 'update_bag'
              include_examples 'checkout securely'
            end
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
      end
    end
  end

  context 'single item in the bag' do
    let(:quantity) { 1 }
    let(:price) { product.price }
    let(:total) { product.price * quantity }
    let(:subtotal) { total }

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

  shared_context 'added_multiple_items' do
    scenario 'bag is populated correctly' do
      bag_path
      no_flash
      shows_each_item(item_count)
      summary
      bag_actions
    end
    include_examples 'checkout securely'
  end

  shared_context 'modify_specific_item' do
    scenario 'can modify an item' do
      within all('#bag #bag-items .bag-item')[target] do
        fill_in 'operations[][quantity]', with: quantity
        click_button 'Save Changes'
      end

      bag_path
      bag_content_header
      flash
      summary
      bag_actions
    end
    include_examples 'checkout securely'
  end

  context 'multiple items in the bag' do
    let(:products) { [] }
    let(:product_count) { rand(1..10) }
    let(:variant_count) { rand(1..10) }
    let(:item_count) { product_count + variant_count }
    let(:subtotal) { products.map(&:price).sum }

    let(:set_bag_shipping_notice) { false }
    let(:sr) { Site.current.shipping_rates.first }
    let(:srr) { Site.current.shipping_rates.first.shipping_rate_regions.first }

    before do
      if set_shipping
        Site.current.shipping_rates
          .create!(name: Faker::Lorem.word, description: Faker::Lorem.word,
                   use_as_bag_shipping: true, enabled: true)
        Site.current.shipping_rates.first.shipping_rate_regions
          .create!(country: Site.current.country, price: rand(1.0..99.99))

        if set_bag_shipping_notice
          Site.current.preferences
            .update(bag_shipping_notice: bag_shipping_notice)
        end
      end

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
      context 'without shipping' do
        let(:set_shipping) { false }
        let(:summary) do
          bag_summary_not_extended(item_count: item_count, subtotal: subtotal)
        end
        include_examples 'added_multiple_items'
      end

      context 'with shipping' do
        let(:set_shipping) { true }
        let(:summary) do
          bag_summary_extended(item_count: item_count, subtotal: subtotal,
                               shipping: srr.price.to_s,
                               total: (subtotal + srr.price).to_s)
        end
        include_examples 'added_multiple_items'

        context 'with shipping notice' do
          let(:set_bag_shipping_notice) { true }
          let(:bag_shipping_notice) { Faker::Lorem.sentence }
          include_examples 'added_multiple_items'
        end
      end
    end

    context 'modifying an item' do
      let(:target) { rand(0...item_count) }
      let(:quantity) { rand(2..20) }
      let(:new_item_count) { item_count - 1 + quantity }
      let(:new_subtotal) do
        subtotal - products[target].price + products[target].price * quantity
      end

      context 'without shipping' do
        let(:set_shipping) { false }
        let(:summary) do
          bag_summary_not_extended(item_count: new_item_count,
                                   subtotal: new_subtotal.to_s)
        end
        include_examples 'modify_specific_item'
      end

      context 'with shipping' do
        let(:set_shipping) { true }
        let(:summary) do
          bag_summary_extended(item_count: new_item_count,
                               subtotal: new_subtotal.to_s,
                               shipping: srr.price.to_s,
                               total: (new_subtotal + srr.price).to_s)
        end
        include_examples 'modify_specific_item'

        context 'with shipping notice' do
          let(:set_bag_shipping_notice) { true }
          let(:bag_shipping_notice) { Faker::Lorem.sentence }
          include_examples 'modify_specific_item'
        end
      end
    end
  end
end
