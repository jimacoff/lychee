require 'rails_helper'

RSpec.describe Order, type: :model, site_scoped: true do
  has_context 'parent site' do
    let(:factory) { :order }
  end
  has_context 'versioned'
  has_context 'metadata'

  context 'table structure' do
    it { is_expected.to have_db_column(:number).of_type(:integer) }
    it { is_expected.to have_db_column(:status).of_type(:string) }
  end

  context 'relationships' do
    it { is_expected.to have_one :customer_address }
    it { is_expected.to have_one :delivery_address }
  end

  context 'validations' do
    it { is_expected.to validate_presence_of :number }
    it { is_expected.to validate_presence_of :status }
    it { is_expected.to validate_length_of(:status).is_at_most(255) }
    it { is_expected.to validate_presence_of :customer_address }
    it { is_expected.to validate_presence_of :delivery_address }

    context 'instance validations' do
      subject { create :order }
    end
  end
end
