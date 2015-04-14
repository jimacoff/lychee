require 'rails_helper'

RSpec.describe Inventory, type: :model, site_scoped: true do
  has_context 'parent site' do
    let(:factory) { :tracked_product_inventory }
  end
  has_context 'item reference' do
    let(:factory) { :untracked_inventory }
  end
  has_context 'versioned'
  has_context 'metadata'

  context 'table structure' do
    it { is_expected.to have_db_column(:tracked).of_type(:boolean) }
    it { is_expected.to have_db_column(:quantity).of_type(:integer) }
    it { is_expected.to have_db_column(:back_orders).of_type(:boolean) }
    it { is_expected.to have_db_column(:replenish_eta).of_type(:datetime) }
    it { is_expected.to have_db_column(:exhausted_on).of_type(:datetime) }
  end

  context 'relationships' do
  end

  context 'validations' do
    context 'when tracked' do
      subject { create :tracked_inventory, product: (create :product) }
      it { is_expected.to validate_presence_of :quantity }
      it 'tracked? is true' do
        expect(subject.tracked?).to be true
      end
    end
    context 'not tracked' do
      subject { create :untracked_inventory, product: (create :product) }
      it { is_expected.not_to validate_presence_of :quantity }
      it '#tracked? is false' do
        expect(subject.tracked?).to be false
      end
    end
  end

  describe '#stock?' do
    it 'is in stock' do
      subject.quantity = 1
      expect(subject.stock?).to be true
    end
    it 'is not in stock' do
      subject.quantity = 0
      expect(subject.stock?).to be false
    end
  end
end
