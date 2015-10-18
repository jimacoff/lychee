require 'rails_helper'

RSpec.describe TaxCategory, type: :model, site_scoped: true do
  has_context 'parent site' do
    let(:factory) { :tax_category }
  end

  has_context 'metadata'
  has_context 'versioned'

  context 'table structure' do
    it { is_expected.to have_db_column(:name).of_type(:string) }
    it 'should have nullable column site_primary_tax_category_id bigint' do
      expect(subject).to have_db_column(:site_primary_tax_category_id)
        .of_type(:integer)
        .with_options(limit: 8, null: true)
    end
    it { is_expected.to have_db_index(:site_primary_tax_category_id) }
  end

  context 'relationships' do
    it 'can be referenced as sites primary tax category' do
      expect(subject).to belong_to(:site_primary_tax_category)
        .class_name('Site')
    end
    it { is_expected.to have_many :tax_rates }
  end

  context 'validations' do
    it { is_expected.to validate_presence_of :name }

    context 'instance validations' do
    end
  end
end
