require 'rails_helper'

RSpec.describe ShoppingCartsController, type: :controller, site_scoped: true do
  let(:cart) { nil }
  before { session[:shopping_cart_id] = cart.try(:id) }

  def operations
    cart.shopping_cart_operations(true)
  end

  let(:uuid) { SecureRandom.uuid }

  context 'patch :update' do
    def run
      patch :update, operations: updates
    end

    shared_context 'shopping cart updates' do
      context 'when no shopping cart exists' do
        context 'with no operations' do
          let(:updates) { [] }

          it 'creates no shopping cart' do
            expect { run }.not_to change(ShoppingCart, :count)
          end
        end

        context 'with an "add to cart" operation' do
          let(:updates) { [commodity_attrs.merge(quantity: 1)] }

          it 'creates a shopping cart' do
            expect { run }.to change(ShoppingCart, :count).by(1)
          end

          it 'assigns the shopping cart to the session' do
            run
            expect(session[:shopping_cart_id]).to eq(ShoppingCart.last.id)
          end

          it 'creates an operation' do
            expect { run }.to change(ShoppingCartOperation, :count).by(1)
          end

          it 'redirects to the shopping cart' do
            run
            expect(response).to redirect_to(shopping_cart_path)
          end

          it 'updates the cart contents' do
            run
            c = ShoppingCart.last.contents
            expect(c.keys.length).to eq(1)
            expect(c.values.first).to include(commodity_item_attrs)
              .and include(quantity: 1)
          end
        end
      end

      context 'when a shopping cart exists' do
        let(:cart) { create(:shopping_cart) }

        context 'with no operations' do
          let(:updates) { [] }

          it 'creates no operations' do
            expect { run }.not_to change { operations }
          end
        end

        context 'with an "add to cart" operation' do
          let(:updates) { [commodity_attrs.merge(quantity: 1)] }

          it 'adds an operation' do
            expect { run }.to change { operations.length }.by(1)
          end

          it 'updates the cart contents' do
            run
            c = ShoppingCart.last.contents
            expect(c.keys.length).to eq(1)
            expect(c.values.first).to include(commodity_item_attrs)
              .and include(quantity: 1)
          end
        end

        context 'with an "update cart" operation' do
          let(:updates) do
            [commodity_attrs.merge(item_uuid: uuid, quantity: 1)]
          end

          before do
            attrs = updates.first.merge(quantity: 3)
            cart.shopping_cart_operations.create!(attrs)
          end

          it 'adds an operation' do
            expect { run }.to change { operations.length }.by(1)
          end

          it 'updates the cart contents' do
            run
            c = cart.reload.contents
            expect(c.keys).to contain_exactly(uuid)
            expect(c.values.first)
              .to include(commodity_item_attrs)
              .and include(quantity: 1, item_uuid: uuid)
          end

          context 'updating the quantity to 0' do
            let(:updates) do
              [commodity_attrs.merge(item_uuid: uuid, quantity: 0)]
            end

            it 'removes the item from the cart' do
              expect { run }.to change { cart.reload.contents }.to be_empty
            end
          end

          context 'updating the cart to the same contents' do
            it 'creates no new operations' do
              run
              expect { run }.not_to change { operations.length }
            end
          end
        end
      end
    end

    context 'for a product' do
      let(:product) { create(:product) }
      let(:commodity_attrs) { { product_id: product.id } }
      let(:commodity_item_attrs) { { product: product } }

      include_context 'shopping cart updates'
    end

    context 'for a product with metadata' do
      let(:product) { create(:product) }
      let(:metadata) { { 'a' => '1', 'b' => '2', 'c' => '3' } }
      let(:commodity_attrs) { { product_id: product.id, metadata: metadata } }
      let(:commodity_item_attrs) { { product: product, metadata: metadata } }

      include_context 'shopping cart updates'
    end

    context 'for a variant' do
      let(:variant) { create(:variant) }
      let(:commodity_attrs) { { variant_id: variant.id } }
      let(:commodity_item_attrs) { { variant: variant } }

      include_context 'shopping cart updates'
    end

    context 'for a variant with metadata' do
      let(:variant) { create(:variant) }
      let(:metadata) { { 'a' => '1', 'b' => '2', 'c' => '3' } }
      let(:commodity_attrs) { { variant_id: variant.id, metadata: metadata } }
      let(:commodity_item_attrs) { { variant: variant, metadata: metadata } }

      include_context 'shopping cart updates'
    end
  end

  context 'get :show' do
    let(:cart) { create(:shopping_cart) }

    before { get :show }
    subject { response }

    it { is_expected.to have_http_status(:ok) }
    it { is_expected.to render_template('shopping_carts/show') }

    it 'assigns the cart' do
      expect(assigns[:cart]).to eq(cart)
    end

    context 'with a non-empty cart' do
      let(:products) { create_list(:product, 3) }

      let(:cart) do
        create(:shopping_cart).tap do |cart|
          products.each { |p| cart.apply(product_id: p.id, quantity: 1) }
        end
      end

      it 'assigns the contents' do
        expect(assigns[:contents]).to eq(cart.contents.values)
      end
    end
  end

  context 'post :add' do
    def run
      post :add, opts
    end

    shared_context 'add to cart' do
      let(:opts) { commodity_opts }

      context 'with no cart' do
        let(:cart) { nil }

        it 'adds the item to a new cart' do
          expect { run }.to change(ShoppingCart, :count).by(1)
          expect(assigns[:cart].contents.values)
            .to contain_exactly(include(commodity_item_attrs))
        end

        it 'redirects to the cart' do
          run
          expect(response).to redirect_to(shopping_cart_path)
        end
      end

      context 'with an existing cart' do
        let!(:cart) { create(:shopping_cart) }

        it 'adds the item to the cart' do
          run
          expect(cart.contents.values)
            .to contain_exactly(include(commodity_item_attrs))
        end

        it 'redirects to the cart' do
          run
          expect(response).to redirect_to(shopping_cart_path)
        end
      end
    end

    context 'for a product' do
      let(:product) { create(:product) }
      let(:commodity_opts) { { product_id: product.id } }
      let(:commodity_item_attrs) { { product: product, quantity: 1 } }

      include_context 'add to cart'

      context 'with metadata' do
        let(:commodity_opts) do
          { product_id: product.id, metadata: { x: 'y' } }
        end

        let(:commodity_item_attrs) do
          { product: product, quantity: 1, metadata: { 'x' => 'y' } }
        end

        include_context 'add to cart'
      end
    end

    context 'for a variant' do
      def create_default_values(trait)
        trait.default_values.reduce({}) do |hash, value|
          attrs = { name: value, order: 1, description: 'x' }
          hash.merge(value => size.variation_values.create!(attrs))
        end
      end

      def create_variation_instance(variant, variation, variation_value)
        attrs = { variation_id: variation.id,
                  variation_value_id: variation_value.id }
        variant.variation_instances.create!(attrs)
      end

      def variant_with(size_value, color_value)
        create(:variant, product: product).tap do |variant|
          create_variation_instance(variant, size, size_value)
          create_variation_instance(variant, color, color_value)
        end
      end

      let(:color_trait) do
        create(:trait, name: 'Color', default_values: %w(z y))
      end

      let(:size_trait) do
        create(:trait, name: 'Size', default_values: %w(a b))
      end

      let(:size_values)  { create_default_values(size_trait) }
      let(:color_values) { create_default_values(color_trait) }

      let(:color) { create(:variation, product: product, trait: color_trait) }
      let(:size) { create(:variation, product: product, trait: size_trait) }

      let!(:wrong_variants) do
        size_values.values.product(color_values.values).map do |s, c|
          next if s.name == 'a' && c.name == 'z'
          variant_with(s, c)
        end
      end

      let!(:variant) { variant_with(size_values['a'], color_values['z']) }
      let(:product) { create(:product) }

      let(:commodity_opts) do
        {
          product_id: product.id,
          variations: {
            size.id => size_values['a'].id,
            color.id => color_values['z'].id
          }
        }
      end

      let(:commodity_item_attrs) { { variant: variant, quantity: 1 } }

      include_context 'add to cart'

      context 'with metadata' do
        let(:commodity_opts) do
          {
            product_id: product.id,
            variations: {
              size.id => size_values['a'].id,
              color.id => color_values['z'].id
            },
            metadata: { x: 'y' }
          }
        end

        let(:commodity_item_attrs) do
          { variant: variant, quantity: 1, metadata: { 'x' => 'y' } }
        end

        include_context 'add to cart'
      end
    end
  end
end
