require 'rails_helper'

RSpec.describe ShoppingBagOperation, type: :model, site_scoped: true do
  let(:bag) { create(:shopping_bag) }

  subject { build(:shopping_bag_operation) }

  has_context 'parent site' do
    let(:factory) { [:shopping_bag_operation, :for_product] }
  end

  has_context 'commodity reference', indexed: false do
    let(:factory) { :shopping_bag_operation }
  end

  context 'table structure' do
    it { is_expected.to have_db_column(:item_uuid).of_type(:uuid) }
    it { is_expected.to have_db_column(:quantity).of_type(:integer) }
    it { is_expected.to have_db_column(:metadata).of_type(:hstore) }
    it { is_expected.not_to have_db_column(:metadata_fields).of_type(:json) }
  end

  context 'relationships' do
    it { is_expected.to belong_to(:shopping_bag) }
    it { is_expected.to belong_to(:product) }
    it { is_expected.to belong_to(:variant) }
  end

  context 'validations' do
    it { is_expected.to validate_presence_of(:shopping_bag) }
    it { is_expected.not_to validate_presence_of(:product) }
    it { is_expected.not_to validate_presence_of(:variant) }
    it { is_expected.to validate_presence_of(:item_uuid) }
    it { is_expected.to validate_presence_of(:quantity) }
    it 'requires metadata not to be nil' do
      expect(subject).to allow_value('a' => '1').for(:metadata)
      expect(subject).to allow_value({}).for(:metadata)
      expect(subject).not_to allow_value(nil).for(:metadata)
    end
  end

  context '::by_uuid' do
    let!(:ops) do
      create_list(:shopping_bag_operation, 5, :for_product,
                  shopping_bag: bag)
    end

    it 'scopes the operations by uuid' do
      scope = ShoppingBagOperation.by_uuid(ops[0..1].map(&:item_uuid))
      expect(scope).to contain_exactly(*ops[0..1])
    end
  end

  context '#matches_commodity?' do
    let(:product) { nil }
    let(:variant) { nil }
    let(:metadata) { {} }
    let(:op) { create(:shopping_bag_operation, attrs) }

    let(:attrs) do
      { product_id: product.try(:id), variant_id: variant.try(:id),
        metadata: metadata }
    end

    context 'with a product' do
      let(:product) { create(:product) }

      it 'indicates a match' do
        expect(op.matches_commodity?(attrs)).to be_truthy
      end

      it 'indicates a mismatched product' do
        other = create(:product)
        opts = attrs.merge(product_id: other.id)
        expect(op.matches_commodity?(opts)).to be_falsey
      end

      it 'addition of new metadata (blank vs value)' do
        opts = attrs.merge(metadata: { 'a' => '1' })
        expect(op.matches_commodity?(opts)).to be_truthy
      end

      it 'indicates a mismatch when variant is present' do
        variant = create(:variant)
        opts = attrs.merge(variant_id: variant.id)
        expect(op.matches_commodity?(opts)).to be_falsey
      end

      context 'with metadata' do
        let(:metadata) { { 'b' => '2' } }

        it 'indicates a match' do
          expect(op.matches_commodity?(attrs)).to be_truthy
        end

        it 'indicates a mismatched product' do
          other = create(:product)
          opts = attrs.merge(product_id: other.id)
          expect(op.matches_commodity?(opts)).to be_falsey
        end

        it 'removal of all metadata (blank vs value)' do
          opts = attrs.merge(metadata: {})
          expect(op.matches_commodity?(opts)).to be_truthy
        end

        it 'updated metadata (different values)' do
          opts = attrs.merge(metadata: { 'a' => '1' })
          expect(op.matches_commodity?(opts)).to be_truthy
        end

        it 'indicates a mismatch when variant is present' do
          variant = create(:variant)
          opts = attrs.merge(variant_id: variant.id)
          expect(op.matches_commodity?(opts)).to be_falsey
        end
      end
    end

    context 'with a variant' do
      let(:variant) { create(:variant) }

      it 'indicates a match' do
        expect(op.matches_commodity?(attrs)).to be_truthy
      end

      it 'indicates a mismatched variant' do
        other = create(:variant)
        opts = attrs.merge(variant_id: other.id)
        expect(op.matches_commodity?(opts)).to be_falsey
      end

      it 'addition of new metadata (blank vs value)' do
        opts = attrs.merge(metadata: { 'a' => '1' })
        expect(op.matches_commodity?(opts)).to be_truthy
      end

      it 'indicates a mismatch when product is present' do
        product = create(:product)
        opts = attrs.merge(product_id: product.id)
        expect(op.matches_commodity?(opts)).to be_falsey
      end

      context 'with metadata' do
        let(:metadata) { { 'b' => '2' } }

        it 'indicates a match' do
          expect(op.matches_commodity?(attrs)).to be_truthy
        end

        it 'indicates a mismatched variant' do
          other = create(:variant)
          opts = attrs.merge(variant_id: other.id)
          expect(op.matches_commodity?(opts)).to be_falsey
        end

        it 'removal of all metadata (blank vs value)' do
          opts = attrs.merge(metadata: {})
          expect(op.matches_commodity?(opts)).to be_truthy
        end

        it 'updated metadata (different values)' do
          opts = attrs.merge(metadata: { 'a' => '1' })
          expect(op.matches_commodity?(opts)).to be_truthy
        end

        it 'indicates a mismatch when product is present' do
          product = create(:product)
          opts = attrs.merge(product_id: product.id)
          expect(op.matches_commodity?(opts)).to be_falsey
        end
      end
    end
  end

  context '#item_attrs' do
    context 'with a product' do
      let(:product) { create(:product) }

      let(:operation) do
        create(:shopping_bag_operation, metadata: { 'a' => 'b' },
                                        product: product)
      end

      subject { operation.item_attrs }

      it { is_expected.to include(product: operation.product) }
      it { is_expected.not_to have_key(:variant) }
      it { is_expected.to include(item_uuid: operation.item_uuid) }
      it { is_expected.to include(quantity: operation.quantity) }
      it { is_expected.to include(metadata: operation.metadata) }
    end

    context 'with a variant' do
      let(:variant) { create(:variant) }

      let(:operation) do
        create(:shopping_bag_operation, metadata: { 'a' => 'b' },
                                        variant: variant)
      end

      subject { operation.item_attrs }

      it { is_expected.not_to have_key(:product) }
      it { is_expected.to include(variant: operation.variant) }
      it { is_expected.to include(item_uuid: operation.item_uuid) }
      it { is_expected.to include(quantity: operation.quantity) }
      it { is_expected.to include(metadata: operation.metadata) }
    end
  end
end
