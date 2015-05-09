require 'rails_helper'

RSpec.describe ShippingLineItem, type: :model, site_scoped: true do
  has_context 'line item' do
    let(:factory) { :shipping_line_item }
    let(:owner) { :shipping_rate_region }
    let(:owner_factory) { :shipping_rate_region }
    let(:expected_subtotal) { subject.price }
  end

  context 'table structure' do
  end

  context 'relationships' do
    it do
      is_expected.to belong_to(:shipping_rate_region)
        .class_name('ShippingRateRegion')
    end
  end

  context 'validations' do
    it { is_expected.to validate_presence_of :shipping_rate_region }

    context 'instance validations' do
    end
  end

  context 'initial price is populated from shipping_rate_region' do
    subject { create :shipping_line_item }
    it 'is expected to set price to shipping_rate_region price' do
      expect(subject.price).to eq(subject.shipping_rate_region.price)
    end
  end
end
