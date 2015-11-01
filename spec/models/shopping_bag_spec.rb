require 'rails_helper'

RSpec.describe ShoppingBag, type: :model, site_scoped: true do
  subject { create(:shopping_bag) }

  def create_op(attrs)
    attrs[:item_uuid] ||= SecureRandom.uuid
    attrs[:metadata] ||= {}
    subject.shopping_bag_operations.create!(attrs)
  end

  has_context 'parent site' do
    let(:factory) { :shopping_bag }
  end

  context 'table structure' do
    it { is_expected.to have_db_column(:workflow_state).of_type(:string) }
  end

  context 'relationships' do
    it { is_expected.to belong_to(:site) }
    it { is_expected.to have_many(:shopping_bag_operations) }
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
      subject.shopping_bag_operations
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

    shared_examples 'an operable bag item' do
      let!(:commodity) { create(kind) }
      let(:commodity_attrs) { { "#{kind}_id": commodity.id, metadata: {} } }

      context 'with no uuid provided' do
        let(:attrs) { commodity_attrs.merge(quantity: 1) }
        include_examples 'apply the operation successfully'

        context 'when a larger quantity is supplied' do
          let(:attrs) do
            commodity_attrs.merge(quantity: 5)
          end
          include_examples 'apply the operation successfully'
        end

        context 'when metadata is supplied' do
          let(:attrs) do
            commodity_attrs.merge(quantity: 1, metadata: { 'k' => 'v' })
          end
          include_examples 'apply the operation successfully'
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
          let(:op_attrs) { attrs.merge(shopping_bag: subject, quantity: 3) }
          let!(:op) { subject.shopping_bag_operations.create!(op_attrs) }

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

          context 'with no change' do
            let(:op_attrs) { attrs }

            it 'does not create an operation' do
              expect { run }.not_to change { operations.count }
            end
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
      it_behaves_like 'an operable bag item'
    end

    context 'with a variant' do
      let(:kind) { :variant }
      it_behaves_like 'an operable bag item'
    end
  end

  context '#contents' do
    it 'returns all items' do
      products = create_list(:product, 3)
      variants = create_list(:variant, 3)
      uuids = (1..6).to_a.map { SecureRandom.uuid }

      products.zip(uuids[0..2]).each do |(p, u)|
        create_op(product_id: p.id, quantity: 1, item_uuid: u)
      end

      variants.zip(uuids[3..5]).each do |(v, u)|
        create_op(variant_id: v.id, quantity: 1, item_uuid: u)
      end

      base = { quantity: 1, metadata: {} }

      expect(subject.contents).to eq(
        uuids[0] => base.merge(product: products[0], item_uuid: uuids[0]),
        uuids[1] => base.merge(product: products[1], item_uuid: uuids[1]),
        uuids[2] => base.merge(product: products[2], item_uuid: uuids[2]),
        uuids[3] => base.merge(variant: variants[0], item_uuid: uuids[3]),
        uuids[4] => base.merge(variant: variants[1], item_uuid: uuids[4]),
        uuids[5] => base.merge(variant: variants[2], item_uuid: uuids[5])
      )
    end

    it 'supersedes with later versions of the same item' do
      uuid1 = SecureRandom.uuid
      uuid2 = SecureRandom.uuid
      product1, product2 = create_list(:product, 2)

      create_op(product_id: product1.id, quantity: 1, item_uuid: uuid1)
      create_op(product_id: product2.id, quantity: 1, item_uuid: uuid2)
      create_op(product_id: product1.id, quantity: 2, item_uuid: uuid1)
      create_op(product_id: product1.id, quantity: 4, item_uuid: uuid1)
      create_op(product_id: product2.id, quantity: 20, item_uuid: uuid2)

      expect(subject.contents).to eq(
        uuid1 => { product: product1, quantity: 4,
                   item_uuid: uuid1, metadata: {} },
        uuid2 => { product: product2, quantity: 20,
                   item_uuid: uuid2, metadata: {} }
      )
    end

    it 'returns items with metadata' do
      product = create(:product)

      create_op(product_id: product.id, quantity: 1, metadata: { 'x' => '1' })
      create_op(product_id: product.id, quantity: 2, metadata: { 'y' => '2' })

      base = { product: product, item_uuid: anything }

      expect(subject.contents.values).to contain_exactly(
        base.merge(quantity: 1, metadata: { 'x' => '1' }),
        base.merge(quantity: 2, metadata: { 'y' => '2' })
      )
    end

    it 'removes items with no quantity' do
      product = create(:product)

      create_op(product_id: product.id, quantity: 0)

      expect(subject.contents).to be_empty
    end

    it 'queries the shopping bag efficiently' do
      product = create(:product)

      (1..10).each do |i|
        create_op(product_id: product.id, quantity: i)
      end

      expect { subject.reload.contents }.not_to exceed_query_limit(4)
    end
  end

  context 'ui helpers' do
    let(:uuid1) { SecureRandom.uuid }
    let(:uuid2) { SecureRandom.uuid }
    let(:uuid3) { SecureRandom.uuid }

    let(:qty1) { rand(5..20) }
    let(:qty2) { rand(10..50) }

    let(:product1) { create :product }
    let(:product2) { create :product }
    let(:product3) { create :product }

    before do
      create_op(product_id: product1.id, quantity: qty1, item_uuid: uuid1)
      create_op(product_id: product2.id, quantity: qty2, item_uuid: uuid2)
      create_op(product_id: product3.id, quantity: 0, item_uuid: uuid3)
    end

    describe '#subtotal' do
      it 'equals addition of price * qty for all bag items' do
        expect(subject.subtotal)
          .to eq(product1.price * qty1 + product2.price * qty2)
      end
    end

    describe 'item_count' do
      it 'equals tot quantity of items in the bag' do
        expect(subject.item_count).to eq(qty1 + qty2)
      end
    end
  end
end
