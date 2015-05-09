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
  has_context 'enablement' do
    let(:factory) { :shipping_rate_region }
  end

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
    it { is_expected.to belong_to(:tax_override).class_name('TaxCategory') }
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

  context 'scopes' do
    describe 'supports_location' do
      let(:au) { create :country, iso_alpha2: 'au' }

      let(:qld) { create :state, iso_code: 'qld', country: au }
      let(:nsw) { create :state, iso_code: 'nsw', country: au }

      let!(:sr) { create :shipping_rate }
      let!(:r1) do
        create :shipping_rate_region, country: au, shipping_rate: sr
      end
      let!(:r1d) do
        create :shipping_rate_region, country: au, state: nsw,
                                      shipping_rate: sr, enabled: false
      end
      let!(:r2) do
        create :shipping_rate_region, country: au, state: qld, shipping_rate: sr
      end
      let!(:r3) do
        create :shipping_rate_region, country: au, state: qld,
                                      postcode: '4000', shipping_rate: sr
      end

      it 'provides specific result' do
        expect(described_class.supports_location('au.qld.4000'))
          .to contain_exactly(r3)
      end

      it 'provides higher level result as specific result disabled' do
        expect(described_class.supports_location('au.nsw.2000'))
          .to contain_exactly(r1)
      end

      it 'provides nil if non matching result' do
        expect(described_class.supports_location('nz')).to be_empty
      end
    end
  end
end
