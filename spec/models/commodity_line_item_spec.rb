require 'rails_helper'

RSpec.describe CommodityLineItem, type: :model, site_scoped: true do
  has_context 'line item', :commodity_line_item
  has_context 'line item', :commodity_variant_line_item

  has_context 'commodity reference' do
    let(:factory) { :commodity_line_item }
  end
  has_context 'commodity reference' do
    let(:factory) { :commodity_variant_line_item }
  end

  context 'table structure' do
  end

  context 'relationships' do
  end

  context 'validations' do
    it { is_expected.to validate_numericality_of :quantity }
    it { is_expected.to validate_numericality_of :weight }
    it { is_expected.to validate_numericality_of :total_weight }

    context 'instance validations' do
    end
  end

  context 'initial weight and price is populated from commodity' do
    let(:product) { create :product }
    let(:variant) { create :variant, product: product }

    RSpec.shared_examples 'commodity initialization' do
      let(:qty) { Faker::Number.number(2).to_i + 1 }

      it 'is expected to set price to commodity price' do
        expect(subject.price).to eq(commodity.price)
      end

      it 'is expected to set weight to commodity weight' do
        expect(subject.weight).to eq(commodity.weight)
      end
    end

    context 'with Product' do
      let(:commodity) { product }
      subject { create :commodity_line_item, product: product, quantity: qty }

      include_examples 'commodity initialization'

      describe '#commodity' do
        it 'provides the product' do
          expect(subject.commodity).to eq(product)
        end
      end
    end

    context 'with Variant' do
      let(:commodity) { variant }
      subject do
        create :commodity_variant_line_item, variant: variant, quantity: qty
      end

      include_examples 'commodity initialization'

      describe '#commodity' do
        it 'provides the variant' do
          expect(subject.commodity).to eq(variant)
        end
      end
    end
  end

  describe '#total' do
    subject { create :commodity_line_item }
    let(:expected_total) { subject.price * subject.quantity }

    it 'has order currency' do
      expect(subject.total.currency).to eq(subject.order.currency)
    end
    it 'is a Money instance' do
      expect(subject.total).to be_a(Money)
    end

    pending 'more examples post workflow implementation'
  end
end
