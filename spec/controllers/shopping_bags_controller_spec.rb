require 'rails_helper'

RSpec.describe ShoppingBagsController, type: :controller, site_scoped: true do
  let(:bag) { nil }
  before { session[:shopping_bag_id] = bag.try(:id) }

  def operations
    bag.shopping_bag_operations(true)
  end

  let(:uuid) { SecureRandom.uuid }

  context 'patch :update' do
    def run
      patch :update, operations: updates
    end

    shared_context 'shopping bag updates' do
      context 'when no shopping bag exists' do
        context 'with no operations' do
          let(:updates) { [] }

          it 'creates no shopping bag' do
            expect { run }.not_to change(ShoppingBag, :count)
          end
        end

        context 'with an "add to bag" operation' do
          let(:updates) { [commodity_attrs.merge(quantity: 1)] }

          it 'creates a shopping bag' do
            expect { run }.to change(ShoppingBag, :count).by(1)
          end

          it 'assigns the shopping bag to the session' do
            run
            expect(session[:shopping_bag_id]).to eq(ShoppingBag.last.id)
          end

          it 'creates an operation' do
            expect { run }.to change(ShoppingBagOperation, :count).by(1)
          end

          it 'redirects to the shopping bag' do
            run
            expect(response).to redirect_to(shopping_bag_path)
          end

          it 'updates the bag contents' do
            run
            c = ShoppingBag.last.contents
            expect(c.keys.length).to eq(1)
            expect(c.values.first).to include(commodity_item_attrs)
              .and include(quantity: 1)
          end
        end
      end

      context 'when a shopping bag exists' do
        let(:bag) { create(:shopping_bag) }

        context 'with no operations' do
          let(:updates) { [] }

          it 'creates no operations' do
            expect { run }.not_to change { operations }
          end
        end

        context 'with an "add to bag" operation' do
          let(:updates) { [commodity_attrs.merge(quantity: 1)] }

          it 'adds an operation' do
            expect { run }.to change { operations.length }.by(1)
          end

          it 'updates the bag contents' do
            run
            c = ShoppingBag.last.contents
            expect(c.keys.length).to eq(1)
            expect(c.values.first).to include(commodity_item_attrs)
              .and include(quantity: 1)
          end
        end

        context 'with an "update bag" operation' do
          let(:updates) do
            [commodity_attrs.merge(item_uuid: uuid, quantity: 1, metadata: {})]
          end
          let(:attrs) do
            updates.first.merge(quantity: 3)
          end

          before { bag.shopping_bag_operations.create!(attrs) }

          it 'adds an operation' do
            expect { run }.to change { operations.length }.by(1)
          end

          it 'updates the bag contents' do
            run
            c = bag.reload.contents
            expect(c.keys).to contain_exactly(uuid)
            expect(c.values.first)
              .to include(commodity_item_attrs.except(:metadata))
              .and include(quantity: 1, item_uuid: uuid)
          end

          it 'sets flash to indicate update' do
            run
            expect(flash[:updated]).to be_truthy
          end

          context 'updating the quantity to 0' do
            let(:updates) do
              [commodity_attrs.merge(item_uuid: uuid, quantity: 0,
                                     metadata: {})]
            end

            it 'removes the item from the bag' do
              expect { run }.to change { bag.reload.contents }.to be_empty
            end
          end

          context 'updating the bag to the same contents' do
            it 'creates no new operations' do
              run
              expect { run }.not_to change { operations.length }
            end
          end

          context 'additional specific actions' do
            context 'remove item' do
              let(:updates) do
                [commodity_attrs.merge(item_uuid: uuid, quantity: 1,
                                       metadata: {},
                                       additional_action: 'remove')]
              end
              let(:attrs) do
                commodity_attrs.merge(item_uuid: uuid, quantity: 3,
                                      metadata: {})
              end

              it 'removes the item from the bag' do
                expect { run }.to change { bag.reload.contents }.to be_empty
              end
            end
          end
        end
      end
    end

    context 'for a product' do
      let(:product) { create(:product) }
      let(:commodity_attrs) { { product_id: product.id } }
      let(:commodity_item_attrs) { { product: product } }

      include_context 'shopping bag updates'
    end

    context 'for a product with metadata' do
      let(:metadata) { { 'a' => '1', 'b' => '2' } }
      let(:expected_metadata) { metadata }
      let(:metadata_fields) do
        { a: { submissible: true }, b: { submissible: true } }
      end
      let(:product) { create(:product, metadata_fields: metadata_fields) }
      let(:commodity_attrs) { { product_id: product.id, metadata: metadata } }
      let(:commodity_item_attrs) do
        { product: product, metadata: expected_metadata }
      end

      include_context 'shopping bag updates'

      context 'with non submissible metadata' do
        let(:metadata) { { 'a' => '1', 'b' => '2', 'c' => '3' } }
        let(:expected_metadata) { { 'a' => '1', 'b' => '2' } }
        include_context 'shopping bag updates'
      end
    end

    context 'for a variant' do
      let(:variant) { create(:variant) }
      let(:commodity_attrs) { { variant_id: variant.id } }
      let(:commodity_item_attrs) { { variant: variant } }

      include_context 'shopping bag updates'
    end

    context 'for a variant with metadata' do
      let(:metadata) { { 'a' => '1', 'b' => '2' } }
      let(:expected_metadata) { metadata }
      let(:metadata_fields) do
        { a: { submissible: true }, b: { submissible: true } }
      end
      let(:product) { create(:product, metadata_fields: metadata_fields) }
      let(:variant) { create(:variant, product: product) }
      let(:commodity_attrs) { { variant_id: variant.id, metadata: metadata } }
      let(:commodity_item_attrs) do
        { variant: variant, metadata: expected_metadata }
      end

      include_context 'shopping bag updates'

      context 'with non submissible metadata' do
        let(:metadata) { { 'a' => '1', 'b' => '2', 'c' => '3' } }
        let(:expected_metadata) { { 'a' => '1', 'b' => '2' } }
        include_context 'shopping bag updates'
      end
    end
  end

  context 'get :show' do
    let(:bag) { create(:shopping_bag) }

    before { get :show }
    subject { response }

    it { is_expected.to have_http_status(:ok) }
    it { is_expected.to render_template('shopping_bags/show') }

    it 'assigns the bag' do
      expect(assigns[:bag]).to eq(bag)
    end

    context 'with a non-empty bag' do
      let(:products) { create_list(:product, 3) }

      let(:bag) do
        create(:shopping_bag).tap do |bag|
          products.each { |p| bag.apply(product_id: p.id, quantity: 1) }
        end
      end

      it 'assigns the contents' do
        expect(assigns[:contents]).to eq(bag.contents.values)
      end
    end
  end

  context 'post :add' do
    def run
      post :add, opts
    end

    shared_context 'add to bag' do
      let(:opts) { commodity_opts }

      context 'with no bag' do
        let(:bag) { nil }

        it 'adds the item to a new bag' do
          expect { run }.to change(ShoppingBag, :count).by(1)
          expect(assigns[:bag].contents.values)
            .to contain_exactly(include(commodity_item_attrs))
        end

        it 'sets flash to indicate add' do
          run
          expect(flash[:updated]).to be_falsey
        end

        it 'redirects to the bag' do
          run
          expect(response).to redirect_to(shopping_bag_path)
        end
      end

      context 'with an existing bag' do
        let!(:bag) { create(:shopping_bag) }

        it 'adds the item to the bag' do
          run
          expect(bag.contents.values)
            .to contain_exactly(include(commodity_item_attrs))
        end

        it 'sets flash to indicate add' do
          run
          expect(flash[:updated]).to be_falsey
        end

        it 'redirects to the bag' do
          run
          expect(response).to redirect_to(shopping_bag_path)
        end

        context 'when the bag is deleted' do
          it 'creates a new bag' do
            bag.destroy
            expect { run }.to change(ShoppingBag, :count).by(1)
            expect(session[:shopping_bag_id]).to eq(ShoppingBag.last.id)
          end
        end
      end
    end

    context 'for a product' do
      let(:product) { create(:product) }
      let(:commodity_opts) { { product_id: product.id } }

      let(:commodity_item_attrs) do
        { product: product, quantity: 1, metadata: {} }
      end

      include_context 'add to bag'

      context 'with metadata' do
        let(:metadata) { { 'a' => '1', 'b' => '2' } }
        let(:expected_metadata) { metadata }
        let(:metadata_fields) do
          { a: { submissible: true }, b: { submissible: true } }
        end
        let(:product) { create(:product, metadata_fields: metadata_fields) }

        let(:commodity_opts) do
          { product_id: product.id, metadata: metadata }
        end

        let(:commodity_item_attrs) do
          { product: product, quantity: 1, metadata: expected_metadata }
        end

        include_context 'add to bag'

        context 'with non submissible metadata' do
          let(:metadata) { { 'a' => '1', 'b' => '2', 'c' => '3' } }
          let(:expected_metadata) { { 'a' => '1', 'b' => '2' } }
          include_context 'add to bag'
        end
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

      let(:commodity_item_attrs) do
        { variant: variant, quantity: 1 }
      end

      include_context 'add to bag'

      context 'with metadata' do
        let(:metadata) { { 'a' => '1', 'b' => '2' } }
        let(:expected_metadata) { metadata }
        let(:metadata_fields) do
          { a: { submissible: true }, b: { submissible: true } }
        end
        let(:product) { create(:product, metadata_fields: metadata_fields) }

        let(:commodity_opts) do
          {
            product_id: product.id,
            variations: {
              size.id => size_values['a'].id,
              color.id => color_values['z'].id
            },
            metadata: metadata
          }
        end

        let(:commodity_item_attrs) do
          { variant: variant, quantity: 1, metadata: expected_metadata }
        end

        include_context 'add to bag'

        context 'with non submissible metadata' do
          let(:metadata) { { 'a' => '1', 'b' => '2', 'c' => '3' } }
          let(:expected_metadata) { { 'a' => '1', 'b' => '2' } }
          include_context 'add to bag'
        end
      end

      context 'adding the parent product' do
        let(:commodity_opts) { { product_id: product.id } }

        it 'adds the item to a new bag' do
          expect { run }.to raise_error(/Product \d+ needs variations/)
        end
      end
    end
  end
end
