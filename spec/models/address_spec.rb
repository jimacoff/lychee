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
    it { is_expected.to have_db_column(:region).of_type(:string) }
    it { is_expected.to have_db_column(:postcode).of_type(:string) }
  end

  context 'relationships' do
    it { is_expected.to belong_to(:customer_address_for) }
    it { is_expected.to belong_to(:delivery_address_for) }
    it { is_expected.to belong_to(:country) }
  end

  context 'validations' do
    it { is_expected.to validate_presence_of :line1 }
    it { is_expected.to validate_presence_of :country }

    context 'instance validations' do
      context 'order customer association' do
        subject { create(:address, customer_address_for: (create :order)) }
        it { is_expected.to be_valid }
      end
      context 'order delivery association' do
        subject { create(:address, delivery_address_for: (create :order)) }
        it { is_expected.to be_valid }
      end
    end
  end
end
