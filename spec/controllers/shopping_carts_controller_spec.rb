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
end
