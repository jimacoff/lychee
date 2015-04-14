require 'rails_helper'

RSpec.describe State, type: :model, site_scoped: true do
  has_context 'parent country' do
    let(:factory) { :state }
  end
  has_context 'versioned'

  context 'table structure' do
    it { is_expected.to have_db_column(:name).of_type(:string) }
    it { is_expected.to have_db_column(:iso_code).of_type(:string) }
    it { is_expected.to have_db_column(:postal_format).of_type(:string) }
    it { is_expected.to have_db_column(:tax_code).of_type(:string) }
  end

  context 'relationships' do
  end

  context 'validations' do
    it { is_expected.to validate_presence_of :name }
    it { is_expected.to validate_presence_of :iso_code }
    it { is_expected.to validate_presence_of :postal_format }
    it { is_expected.to validate_presence_of :tax_code }

    context 'instance validations' do
    end
  end
end
