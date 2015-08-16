require 'rails_helper'

RSpec.describe CommodityLineItem, type: :model, site_scoped: true do
  has_context 'line item' do
    let(:factory) { [:commodity_line_item, :with_product] }
    let(:owner) { :product }
    let(:owner_factory) { :standalone_product }
    let(:expected_subtotal) { subject.price * subject.quantity }
  end
  has_context 'line item' do
    let(:factory) { [:commodity_line_item, :with_variant] }
    let(:owner) { :variant }
    let(:owner_factory) { :variant }
    let(:expected_subtotal) { subject.price * subject.quantity }
  end

  has_context 'commodity reference' do
    let(:factory) { :commodity_line_item }
  end
  has_context 'commodity reference' do
    let(:factory) { :commodity_line_item }
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
        create :commodity_line_item, variant: variant, quantity: qty
      end

      include_examples 'commodity initialization'

      describe '#commodity' do
        it 'provides the variant' do
          expect(subject.commodity).to eq(variant)
        end
      end
    end
  end

  describe '#calculate_total_weight' do
    context 'product referencing line item' do
      subject { create :commodity_line_item, :with_product }
      before { subject.calculate_total_weight }

      context 'product has weight' do
        let(:expected_weight) { subject.weight * subject.quantity }
        let(:product) do
          create :standalone_product, weight: Faker::Number.number(5)
        end
        it 'sets expected total_weight' do
          expect(subject.total_weight).to eq(expected_weight)
        end
      end

      context 'product has zero weight' do
        let(:expected_weight) { 0 }
        let(:product) do
          create :standalone_product, weight: nil
        end
        it 'sets expected total_weight' do
          expect(subject.total_weight).to eq(expected_weight)
        end
      end
    end
  end
end
