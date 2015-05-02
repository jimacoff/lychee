require 'rails_helper'

RSpec.describe ShippingRateRegion, type: :model, site_scoped: true do
  has_context 'parent site' do
    let(:factory) { :shipping_rate_region }
  end
  has_context 'parent country' do
    let(:factory) { :shipping_rate_region }
  end
  has_context 'parent state' do
    let(:factory) { :shipping_rate_region }
  end
  has_context 'geographic hierarchy' do
    let(:factory) { :shipping_rate_region }
  end
  has_context 'versioned'
  has_context 'metadata'

  has_context 'monies',
              :shipping_rate_region,
              [{ field: :price, calculated: false }]

  context 'table structure' do
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
      subject { create :shipping_rate_region }

      context 'hierarchy per priority' do
        let(:new_rate) do
          build :shipping_rate_region, country: subject.country,
                                       shipping_rate: subject.shipping_rate
        end
        let(:new_rate_alt_site) do
          build :shipping_rate_region, site: create(:site),
                                       country: subject.country
        end
        it 'fails to create new shipping region record when duplicate' do
          new_rate.valid?
          expect(new_rate.errors.size).to eq(1)
          expect(new_rate.errors[:geographic_hierarchy].size).to eq(1)
        end

        it 'new shipping region record when dup but different shipping_rate' do
          expect(new_rate_alt_site).to be_valid
        end
      end
    end
  end
end
