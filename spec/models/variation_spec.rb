require 'rails_helper'

RSpec.describe Variation, type: :model, site_scoped: true do
  has_context 'parent site' do
    let(:factory) { :variation }
  end

  has_context 'versioned'
  has_context 'metadata'

  context 'table structure' do
    it { is_expected.to have_db_column(:order).of_type(:integer) }

    it 'should have non nullable column product_id of type bigint' do
      expect(subject).to have_db_column(:product_id)
        .of_type(:integer)
        .with_options(limit: 8, null: false)
    end
    it { is_expected.to have_db_index(:product_id) }

    it 'should have non nullable column trait_id of type bigint' do
      expect(subject).to have_db_column(:trait_id)
        .of_type(:integer)
        .with_options(limit: 8, null: false)
    end
    it { is_expected.to have_db_index(:trait_id) }
  end

  context 'relationships' do
    it { is_expected.to belong_to(:product).class_name('Product') }
    it { is_expected.to belong_to(:trait).class_name('Trait') }
    it { is_expected.to have_many :variation_instances }
    it { is_expected.to have_many :variants }
  end

  context 'validations' do
    it { is_expected.to validate_presence_of :product }
    it { is_expected.to validate_presence_of :trait }
    it { is_expected.to validate_presence_of(:order) }
    it { is_expected.to validate_numericality_of(:order).only_integer }
  end

  it 'only allow integers for order which are greater than or equal to 0' do
    subject { create :variation }
    expect(subject).to validate_numericality_of(:order)
      .only_integer
      .is_greater_than_or_equal_to 0
  end

  context 'order must be unique within a single product' do
    let(:product) { create :product }
    let(:variation) { create :variation, product: product }
    let(:variation2) { create :variation, product: product }

    context 'within a single product' do
      it 'is valid when order is unique' do
        expect(variation).to be_valid
        expect(variation2).to be_valid
      end

      it 'is invalid when order is not unique' do
        variation.order = variation2.order
        expect(variation).not_to be_valid
        expect(variation2).to be_valid  # not dirty hence still valid
      end
    end

    context 'across products' do
      let(:product2) { create :product }
      let(:variation3) { create :variation, product: product2 }

      it 'is valid when order is not unique across products' do
        variation3.order = variation.order
        expect(variation).to be_valid
        expect(variation2).to be_valid
        expect(variation3).to be_valid
      end
    end
  end
end
