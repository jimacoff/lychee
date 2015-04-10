require 'rails_helper'

RSpec.describe TaxCategory, type: :model, site_scoped: true do
  has_context 'parent site' do
    let(:factory) { :tax_category }
    let(:site_factory_instances) { 1 }
  end
  has_context 'metadata'
  has_context 'versioned'
  # Add additonal shared contexts

  context 'table structure' do
    it { is_expected.to have_db_column(:name).of_type(:string) }
    it do
      is_expected.to have_db_column(:site_primary_tax_category_id)
        .of_type(:integer)
    end
  end

  context 'relationships' do
    it { is_expected.to have_many :tax_rates }
  end

  context 'validations' do
    it { is_expected.to validate_presence_of :name }

    context 'instance validations' do
      # subject { create :tax_category }
    end
  end
end
