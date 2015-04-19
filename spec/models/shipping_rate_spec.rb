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
        let(:subtotal) { 399 }

        it 'matches all shipping rates' do
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

          it 'has 3 possible shipping rates' do
            expect(ShippingRate.count).to eq(3)
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

          it 'has 3 possible shipping rates' do
            expect(ShippingRate.count).to eq(3)
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
  end
end
