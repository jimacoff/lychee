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
    # This must be unrolled because `nil` can't be explicitly assigned.
    it 'validates presence of shipping_rate_region' do
      attrs = FactoryGirl.attributes_for(:shipping_line_item)
      obj = ShippingLineItem.new(attrs.except(:shipping_rate_region))

      expect(obj).to be_invalid
      expect(obj.errors[:shipping_rate_region])
        .to contain_exactly("can't be blank")
    end

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
