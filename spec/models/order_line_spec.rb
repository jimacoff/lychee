require 'rails_helper'

RSpec.describe OrderLine, type: :model, site_scoped: true do
  has_context 'parent site' do
    let(:factory) { :product_order_line }
  end
  has_context 'parent site' do
    let(:factory) { :variant_order_line }
  end
  has_context 'versioned'
  has_context 'metadata'
  has_context 'taggable'
  has_context 'pricing' do
    subject { create :product_order_line }
  end
  has_context 'pricing' do
    subject { create :variant_order_line }
  end
  has_context 'item reference' do
    let(:factory) { :order_line }
  end

  context 'table structure' do
    it { is_expected.to have_db_column(:customisation).of_type(:string) }
    it { is_expected.to have_db_column(:price_cents).of_type(:integer) }
    it { is_expected.to have_db_column(:quantity).of_type(:integer) }
  end

  context 'relationships' do
    it { is_expected.to belong_to :order }
  end

  context 'validations' do
    it { is_expected.to validate_presence_of :order }
    it { is_expected.to validate_presence_of :quantity }

    context 'instance validations' do
    end
  end

  describe '#total' do
    subject { build :order_line }
    it 'represents price * quantity' do
      expect(subject.total).to eq(subject.price * subject.quantity)
    end
    it 'is a Money instance' do
      expect(subject.total).to be_a(Money)
    end
  end
end
