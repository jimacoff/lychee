require 'rails_helper'

RSpec.describe ShippingRateRegion, type: :model, site_scoped: true do
  has_context 'parent site' do
    let(:factory) { :shipping_rate_region }
  end
  has_context 'hierarchy' do
    let(:factory) { :shipping_rate_region }
  end
  has_context 'parent country' do
    let(:factory) { :shipping_rate_region }
  end
  has_context 'parent state' do
    let(:factory) { :shipping_rate_region }
  end
  has_context 'versioned'
  has_context 'metadata'

  has_context 'monies',
              :shipping_rate_region,
              [{ field: :price, calculated: false }]

  context 'table structure' do
    it { is_expected.to have_db_column(:hierarchy).of_type(:ltree) }

    it 'should have non nullable column shipping_rate_id of type bigint' do
      expect(subject).to have_db_column(:shipping_rate_id)
        .of_type(:integer)
        .with_options(limit: 8, null: false)
    end
    it { is_expected.to have_db_index(:shipping_rate_id) }
  end

  context 'relationships' do
    it { is_expected.to belong_to(:shipping_rate) }
  end

  context 'validations' do
    it { is_expected.to validate_presence_of :shipping_rate }

    context 'instance validations' do
    end
  end
end
