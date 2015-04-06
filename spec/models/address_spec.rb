require 'rails_helper'

RSpec.describe Address, type: :model, site_scoped: true do
  has_context 'parent site' do
    let(:factory) { :address }
  end
  has_context 'versioned'
  has_context 'metadata'

  context 'table structure' do
    it { is_expected.to have_db_column(:line1).of_type(:string) }
    it { is_expected.to have_db_column(:line2).of_type(:string) }
    it { is_expected.to have_db_column(:line3).of_type(:string) }
    it { is_expected.to have_db_column(:line4).of_type(:string) }

    it { is_expected.to have_db_column(:locality).of_type(:string) }
    it { is_expected.to have_db_column(:state).of_type(:string) }
    it { is_expected.to have_db_column(:postcode).of_type(:string) }
  end

  context 'relationships' do
    it { is_expected.to belong_to(:order_customer_address) }
    it { is_expected.to belong_to(:order_delivery_address) }
    it { is_expected.to belong_to(:country) }
  end

  context 'validations' do
    it { is_expected.to validate_presence_of :line1 }
    it { is_expected.to validate_presence_of :country }

    context 'instance validations' do
      context 'order customer association' do
        subject { create(:address, order_customer_address: (create :order)) }
        it { is_expected.to be_valid }
      end
      context 'order delivery association' do
        subject { create(:address, order_delivery_address: (create :order)) }
        it { is_expected.to be_valid }
      end
    end
  end

  describe '#to_s' do
    let(:country) { FactoryGirl.create(:country) }
    subject { FactoryGirl.create(:address, country: country) }

    it 'calls the countries format address method' do
      expect(country).to receive(:format_postal_address).with(subject)
      subject.to_s
    end
  end
end
