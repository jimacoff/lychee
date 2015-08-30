require 'rails_helper'

RSpec.describe ShoppingCart, type: :model, site_scoped: true do
  subject { create(:shopping_cart) }

  has_context 'parent site' do
    let(:factory) { :shopping_cart }
  end

  context 'table structure' do
    it { is_expected.to have_db_column(:workflow_state).of_type(:string) }
  end

  context 'relationships' do
    it { is_expected.to belong_to(:site) }
    it { is_expected.to have_many(:shopping_cart_operations) }
  end

  context 'validations' do
    it { is_expected.to validate_presence_of :site }

    # Error condition can't be triggered, but the validation is there:
    # it { is_expected.to validate_presence_of :workflow_state }
  end

  context 'workflow' do
    it_behaves_like 'workflow object', transitions: [], state: :active
    it_behaves_like 'workflow object', transitions: [:abandon],
                                       state: :abandoned
    it_behaves_like 'workflow object', transitions: [:cancel],
                                       state: :cancelled
    it_behaves_like 'workflow object', transitions: [:checkout],
                                       state: :checked_out
    it_behaves_like 'workflow object', transitions: [:checkout, :abandon],
                                       state: :abandoned
    it_behaves_like 'workflow object', transitions: [:checkout, :cancel],
                                       state: :cancelled
  end

  context '#apply' do
    def operations
      subject.shopping_cart_operations
    end

    def run
      subject.apply(attrs)
    end

    shared_examples 'force a new uuid' do
      it 'forces a new uuid' do
        expect { run }.to change { operations.count }.by(1)

        expected = attrs.merge(item_uuid: match(/[0-9a-f-]+/))
        expect(operations.last).to have_attributes(expected)
        expect(operations.last.item_uuid).not_to eq(attrs[:item_uuid])
      end
    end

    shared_examples 'apply the operation successfully' do
      it 'creates an operation' do
        expect { run }.to change { operations.count }.by(1)

        expected = attrs.merge(item_uuid: match(/[0-9a-f-]+/))
        expect(operations.last).to have_attributes(expected)
      end
    end

    shared_examples 'fail validation' do |error|
      it 'raises a validation error' do
        str = "Validation failed: #{error}"
        expect { run }.to raise_error(ActiveRecord::RecordInvalid, str)
      end
    end

    shared_examples 'an operable cart item' do
      let!(:commodity) { create(kind) }
      let(:commodity_attrs) { { :"#{kind}_id" => commodity.id } }

      context 'with no uuid provided' do
        let(:attrs) { commodity_attrs.merge(quantity: 1) }
        include_examples 'apply the operation successfully'

        context 'when the commodity is already in the cart' do
          let(:op_attrs) { attrs.merge(item_uuid: SecureRandom.uuid) }
          let!(:op) { subject.shopping_cart_operations.create!(op_attrs) }

          it 'applies to the existing item' do
            expect { run }.to change { operations.count }.by(1)

            expected = op_attrs.merge(quantity: 2)
            expect(operations.last).to have_attributes(expected)
          end

          it 'only applies to the item with matching metadata' do
            wrong_attrs = op_attrs.merge(item_uuid: SecureRandom.uuid,
                                         quantity: 4, metadata: { 'a' => '1' })
            subject.shopping_cart_operations.create!(wrong_attrs)

            expect { run }.to change { operations.count }.by(1)

            expected = op_attrs.merge(quantity: 2)
            expect(operations.last).to have_attributes(expected)
          end
        end

        context 'when the commodity is in the cart with mismatched metadata' do
          let(:attrs) do
            commodity_attrs.merge(quantity: 1, metadata: { 'a' => '1' },
                                  item_uuid: SecureRandom.uuid)
          end

          let(:op_attrs) { attrs.merge(metadata: { 'b' => '2' }) }
          let!(:op) { subject.shopping_cart_operations.create!(op_attrs) }

          include_examples 'force a new uuid'
        end
      end

      context 'when providing a uuid' do
        let(:attrs) do
          commodity_attrs.merge(quantity: 1, item_uuid: SecureRandom.uuid)
        end

        context 'when the uuid is unknown' do
          include_examples 'force a new uuid'
        end

        context 'when the uuid exists' do
          let(:op_attrs) { attrs.merge(shopping_cart: subject, quantity: 3) }
          let!(:op) { subject.shopping_cart_operations.create!(op_attrs) }

          include_examples 'apply the operation successfully'

          context 'with a mismatched variant' do
            let(:other_variant) { create(:variant) }
            let(:op_attrs) { attrs.merge(variant: other_variant, product: nil) }
            include_examples 'force a new uuid'
          end

          context 'with a mismatched product' do
            let(:other_product) { create(:product) }
            let(:op_attrs) { attrs.merge(product: other_product, variant: nil) }
            include_examples 'force a new uuid'
          end
        end

        context 'with a nonexistent item' do
          before { commodity.destroy }
          include_examples 'fail validation',
                           'Must belong to a product or variant'
        end

        context 'when a commodity from another site' do
          let!(:commodity) { create(kind, site: create(:site)) }
          include_examples 'fail validation',
                           'Must belong to a product or variant'
        end

        context 'when product and variant are both specified' do
          let(:attrs) do
            { variant_id: variant.id, product_id: product.id,
              quantity: 1, item_uuid: SecureRandom.uuid }
          end
          let(:product) { create(:product) }
          let(:variant) { create(:variant) }

          include_examples 'fail validation',
                           'Cannot belong to a product and a variant'
        end
      end
    end

    context 'with a product' do
      let(:kind) { :product }
      it_behaves_like 'an operable cart item'
    end

    context 'with a variant' do
      let(:kind) { :variant }
      it_behaves_like 'an operable cart item'
    end
  end

  context '#contents' do
  end
end
