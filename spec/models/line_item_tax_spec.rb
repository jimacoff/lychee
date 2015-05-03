require 'rails_helper'

RSpec.describe LineItemTax, type: :model, site_scoped: true do
  has_context 'parent site' do
    let(:factory) { :line_item_tax }
  end
  has_context 'versioned'

  context 'table structure' do
    it 'should have non nullable column line_item_id of type bigint' do
      expect(subject).to have_db_column(:line_item_id)
        .of_type(:integer)
        .with_options(limit: 8, null: false)
    end
    it { is_expected.to have_db_index(:line_item_id) }

    it 'should have non nullable column tax_rate_id of type bigint' do
      expect(subject).to have_db_column(:tax_rate_id)
        .of_type(:integer)
        .with_options(limit: 8, null: false)
    end
    it { is_expected.to have_db_index(:tax_rate_id) }
  end

  context 'relationships' do
    it { is_expected.to belong_to(:line_item).class_name('LineItem') }
    it { is_expected.to belong_to(:tax_rate).class_name('TaxRate') }
  end

  context 'validations' do
    it { is_expected.to validate_presence_of :line_item }
    it { is_expected.to validate_presence_of :tax_rate }

    context 'instance validations' do
    end
  end
end
