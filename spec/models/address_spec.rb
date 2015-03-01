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
    # None
  end

  context 'validations' do
    it { is_expected.to validate_presence_of :line1 }
    it { is_expected.to validate_presence_of :country }

    context 'instance validations' do
      # None
    end
  end
end
