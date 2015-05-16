require 'rails_helper'

RSpec.describe OrderTax, type: :model, site_scoped: true do
  has_context 'parent site' do
    let(:factory) { :order_tax }
  end
  has_context 'versioned'
  has_context 'monies', :line_item_tax,
              [{ field: :tax_amount, calculated: false }]

  context 'table structure' do
    it { is_expected.to have_db_column(:used_tax_rate).of_type(:decimal) }

    it 'should have non nullable column order_id of type bigint' do
      expect(subject).to have_db_column(:order_id)
        .of_type(:integer)
        .with_options(limit: 8, null: false)
    end
    it { is_expected.to have_db_index(:order_id) }

    it 'should have non nullable column tax_rate_id of type bigint' do
      expect(subject).to have_db_column(:tax_rate_id)
        .of_type(:integer)
        .with_options(limit: 8, null: false)
    end
    it { is_expected.to have_db_index(:tax_rate_id) }
  end

  context 'relationships' do
    it { is_expected.to belong_to(:order).class_name('Order') }
    it { is_expected.to belong_to(:tax_rate).class_name('TaxRate') }
  end

  context 'validations' do
    it { is_expected.to validate_presence_of :order }
    it { is_expected.to validate_presence_of :tax_rate }

    context 'instance validations' do
      subject { create :order_tax }
      context 'used_tax_rate' do
        it 'must be greater that or equal to 0' do
          expect(subject).to validate_numericality_of(:used_tax_rate)
            .is_greater_than_or_equal_to(0.0)
        end
        it 'must be less than or equal to 0' do
          expect(subject).to validate_numericality_of(:used_tax_rate)
            .is_less_than_or_equal_to(1.0)
        end
      end
    end
  end
end
