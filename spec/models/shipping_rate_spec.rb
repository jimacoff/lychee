require 'rails_helper'

RSpec.describe ShippingRate, type: :model, site_scoped: true do
  has_context 'parent site' do
    let(:factory) { :shipping_rate }
  end
  has_context 'versioned'
  has_context 'metadata'
  has_context 'monies',
              :shipping_rate_with_price_range,
              [{ field: :min_price, calculated: false },
               { field: :max_price, calculated: false }]
  has_context 'enablement' do
    let(:factory) { :shipping_rate }
  end

  context 'table structure' do
    it { is_expected.to have_db_column(:name).of_type(:string) }
    it { is_expected.to have_db_column(:description).of_type(:string) }

    it { is_expected.to have_db_column(:min_weight).of_type(:integer) }
    it { is_expected.to have_db_column(:max_weight).of_type(:integer) }
  end

  context 'relationships' do
    it { is_expected.to have_many(:shipping_rate_regions) }
  end

  context 'validations' do
    it { is_expected.to validate_presence_of :name }
    it { is_expected.to validate_presence_of :description }

    context 'instance validations' do
    end
  end

  context 'scopes' do
    describe 'satisfies_price' do
      context 'does not specify min or max price' do
        let!(:sr1) { create(:shipping_rate) }
        let!(:sr2) { create(:shipping_rate, min_weight: 1000) }
        let!(:sr3) { create(:shipping_rate, enabled: false) }
        let(:subtotal) { 399 }

        it 'matches all enabled shipping rates' do
          expect(ShippingRate.satisfies_price(subtotal).size).to eq(2)
        end
        it 'offers rate 1 and rate 2' do
          expect(ShippingRate.satisfies_price(subtotal)).to include(sr1, sr2)
        end
      end

      context 'specifies min or max price' do
        context 'subtotal not in cents' do
          it 'fails if base units are not provided' do
            expect { ShippingRate.satisfies_price(11.99) }
              .to raise_error('must query in base monetary units')
          end
        end

        context 'subtotal in cents' do
          let!(:sr1) { create(:shipping_rate, min_price: 0, max_price: 99.99) }
          let!(:sr2) do
            create(:shipping_rate, min_price: 75.0, max_price: 999.99)
          end
          let!(:sr3) { create(:shipping_rate, min_price: 1000.0) }
          let!(:sr4) do
            create(:shipping_rate, min_price: 0,
                                   max_price: 99.99, enabled: false)
          end

          context 'order with subtotal of $0' do
            let(:subtotal) { 0 }
            it 'offers 1 shipping rate' do
              expect(ShippingRate.satisfies_price(subtotal).size).to eq(1)
            end
            it 'offers rate 1' do
              expect(ShippingRate.satisfies_price(subtotal)).to include(sr1)
            end
          end

          context 'order with subtotal of $74.99' do
            let(:subtotal) { 74_99 }
            it 'offers 1 shipping rate' do
              expect(ShippingRate.satisfies_price(subtotal).size).to eq(1)
            end
            it 'offers rate 1' do
              expect(ShippingRate.satisfies_price(subtotal)).to include(sr1)
            end
          end

          context 'order with subtotal of $75.00' do
            let(:subtotal) { 75_00 }
            it 'offers 2 shipping rates' do
              expect(ShippingRate.satisfies_price(subtotal).size).to eq(2)
            end
            it 'offers rate 1 and rate 2' do
              expect(ShippingRate.satisfies_price(subtotal))
                .to include(sr1, sr2)
            end
          end

          context 'order with subtotal of $999.99' do
            let(:subtotal) { 999_99 }
            it 'offers 1 shipping rate' do
              expect(ShippingRate.satisfies_price(subtotal).size).to eq(1)
            end
            it 'offers rate 2' do
              expect(ShippingRate.satisfies_price(subtotal)).to include(sr2)
            end
          end

          context 'order with subtotal of $1000.00' do
            let(:subtotal) { 1_000_00 }
            it 'offers 1 shipping rate' do
              expect(ShippingRate.satisfies_price(subtotal).size).to eq(1)
            end
            it 'offers rate 3' do
              expect(ShippingRate.satisfies_price(subtotal)).to include(sr3)
            end
          end
        end
      end
    end

    describe 'satisfies_weight' do
      context 'does not specify min or max weight' do
        let!(:sr1) { create(:shipping_rate) }
        let!(:sr2) { create(:shipping_rate, min_price: 10.00) }
        let!(:sr3) { create(:shipping_rate, min_price: 10.00, enabled: false) }
        let(:weight) { 399 }

        it 'matches all shipping rates' do
          expect(ShippingRate.satisfies_weight(weight).size).to eq(2)
        end
        it 'offers rate 1 and rate 2' do
          expect(ShippingRate.satisfies_weight(weight)).to include(sr1, sr2)
        end
      end

      context 'specifies min or max weight' do
        context 'weight not in base unit' do
          it 'fails if base units are not provided' do
            expect { ShippingRate.satisfies_weight(11.99) }
              .to raise_error('must query in base weight units')
          end
        end

        context 'weight in cents' do
          let!(:sr1) do
            create(:shipping_rate, min_weight: 0, max_weight: 9_999)
          end
          let!(:sr2) do
            create(:shipping_rate, min_weight: 7_500, max_weight: 999_99)
          end
          let!(:sr3) { create(:shipping_rate, min_weight: 100_000) }
          let!(:sr4) do
            create(:shipping_rate, min_weight: 7_500,
                                   max_weight: 999_99, enabled: false)
          end

          context 'order with total weight of 0' do
            let(:weight) { 0 }
            it 'offers 1 shipping rate' do
              expect(ShippingRate.satisfies_weight(weight).size).to eq(1)
            end
            it 'offers rate 1' do
              expect(ShippingRate.satisfies_weight(weight)).to include(sr1)
            end
          end

          context 'order with total weight of 7499' do
            let(:weight) { 74_99 }
            it 'offers 1 shipping rate' do
              expect(ShippingRate.satisfies_weight(weight).size).to eq(1)
            end
            it 'offers rate 1' do
              expect(ShippingRate.satisfies_weight(weight)).to include(sr1)
            end
          end

          context 'order with total weight of 7500' do
            let(:weight) { 75_00 }
            it 'offers 2 shipping rates' do
              expect(ShippingRate.satisfies_weight(weight).size).to eq(2)
            end
            it 'offers rate 1 and rate 2' do
              expect(ShippingRate.satisfies_weight(weight))
                .to include(sr1, sr2)
            end
          end

          context 'order with total weight of 99999' do
            let(:weight) { 999_99 }
            it 'offers 1 shipping rate' do
              expect(ShippingRate.satisfies_weight(weight).size).to eq(1)
            end
            it 'offers rate 2' do
              expect(ShippingRate.satisfies_weight(weight)).to include(sr2)
            end
          end

          context 'order with total weight of 100000' do
            let(:weight) { 1_000_00 }
            it 'offers 1 shipping rate' do
              expect(ShippingRate.satisfies_weight(weight).size).to eq(1)
            end
            it 'offers rate 3' do
              expect(ShippingRate.satisfies_weight(weight)).to include(sr3)
            end
          end
        end
      end
    end

    describe 'supports_location' do
      let(:au) { create :country, iso_alpha2: 'au' }
      let(:nz) { create :country, iso_alpha2: 'nz' }
      let(:us) { create :country, iso_alpha2: 'us' }

      let!(:sr) { create :shipping_rate }
      let!(:r1) do
        create :shipping_rate_region, country: au, shipping_rate: sr
      end
      let!(:r2) do
        create :shipping_rate_region, country: nz, shipping_rate: sr
      end

      let!(:sr2) { create :shipping_rate }
      let!(:r3) do
        create :shipping_rate_region, country: au, shipping_rate: sr2
      end

      let!(:sr3) { create :shipping_rate, enabled: false }
      let(:sr4) { create :shipping_rate }
      let!(:r4) do
        create :shipping_rate_region, country: us, shipping_rate: sr4,
                                      enabled: false
      end

      let(:sr5) { create :shipping_rate, enabled: false }
      let!(:r5) do
        create :shipping_rate_region, country: us, shipping_rate: sr5
      end

      let!(:sr4) { create :shipping_rate }

      it 'indicates multiple shipping rates for location' do
        expect(ShippingRate.supports_location('au.qld'))
          .to contain_exactly(sr, sr2)
      end

      it 'indicates single shipping rate for location' do
        expect(ShippingRate.supports_location('nz')).to contain_exactly(sr)
      end

      it 'indicates no shipping rates for location' do
        expect(ShippingRate.supports_location('ca')).to be_empty
      end

      it 'indicates no shipping rates for location when shipping rate or
          all child shipping rate regions are disabled' do
        expect(ShippingRate.supports_location('us')).to be_empty
      end
    end
  end

  describe '#location' do
    let(:au) { create :country, iso_alpha2: 'au' }

    let!(:sr) { create :shipping_rate }
    let!(:r1) do
      create :shipping_rate_region, country: au, shipping_rate: sr
    end

    it 'is true when region supported' do
      expect(sr.location?('au')).to be
    end

    it 'is false when region unsupported' do
      expect(sr.location?('nz')).not_to be
    end
  end

  describe '#price' do
    let(:au) { create :country, iso_alpha2: 'au' }

    let(:qld) { create :state, iso_code: 'qld', country: au }

    let!(:sr) { create :shipping_rate }
    let!(:r1) do
      create :shipping_rate_region, country: au, shipping_rate: sr
    end
    let!(:r2) do
      create :shipping_rate_region, country: au, state: qld, shipping_rate: sr
    end

    it 'returns price for supported region' do
      expect(sr.price('au.vic')).to eq(r1.price)
    end

    it 'returns price for sub-region with more specific pricing' do
      expect(sr.price('au.qld')).to eq(r2.price)
    end

    it 'throws failure if region not supported' do
      expect { sr.price('nz') }.to raise_exception('region not supported')
    end
  end
end
