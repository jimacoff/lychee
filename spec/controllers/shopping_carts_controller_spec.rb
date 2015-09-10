require 'rails_helper'

RSpec.describe ShoppingCartsController, type: :controller, site_scoped: true do
  let(:cart) { nil }
  before { session[:shopping_cart_id] = cart.try(:id) }

  def operations
    cart.shopping_cart_operations(true)
  end

  let(:product) { create(:product) }
  let(:uuid) { SecureRandom.uuid }

  context 'patch :update' do
    def run
      patch :update, shopping_cart: updates
    end

    context 'when no shopping cart exists' do
      context 'with no operations' do
        let(:updates) { [] }

        it 'creates no shopping cart' do
          expect { run }.not_to change(ShoppingCart, :count)
        end
      end

      context 'with an "add to cart" operation' do
        let(:updates) { [{ product_id: product.id, quantity: 1 }] }

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

        it 'updates the cart contents' do
          run
          c = ShoppingCart.last.contents
          expect(c.keys.length).to eq(1)
          expect(c.values.first).to include(product: product, quantity: 1)
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
        let(:updates) { [{ product_id: product.id, quantity: 1 }] }

        it 'adds an operation' do
          expect { run }.to change { operations.length }.by(1)
        end

        it 'updates the cart contents' do
          run
          c = ShoppingCart.last.contents
          expect(c.keys.length).to eq(1)
          expect(c.values.first).to include(product: product, quantity: 1)
        end
      end

      context 'with an "update cart" operation' do
        let(:updates) do
          [{ item_uuid: uuid, product_id: product.id, quantity: 1 }]
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
            .to include(product: product, quantity: 1, item_uuid: uuid)
        end

        context 'updating the quantity to 0' do
          let(:updates) do
            [{ item_uuid: uuid, product_id: product.id, quantity: 0 }]
          end

          it 'removes the item from the cart' do
            expect { run }.to change { cart.reload.contents }.to be_empty
          end
        end
      end
    end
  end
end
