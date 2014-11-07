require 'rails_helper'

RSpec.describe Inventory, type: :model do
  has_context 'metadata'

  subject { create :tracked_inventory }

  it { is_expected.to validate_presence_of :quantity }

  context '#tracked?' do
    it 'is tracked' do
      subject.tracked = true
      expect(subject.tracked?).to be true
    end
    it 'is not tracked' do
      subject.tracked = false
      expect(subject.tracked?).to be false
    end
  end

  context '#stock?' do
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
