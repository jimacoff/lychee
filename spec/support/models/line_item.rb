require 'rails_helper'

RSpec.shared_examples 'line item' do |line_item_factory|
  has_context 'parent site'do
    let(:factory) { line_item_factory }
  end

  has_context 'versioned'

  has_context 'monies', line_item_factory,
              [{ field: :price, calculated: false },
               { field: :total, calculated: true }]

  has_context 'metadata'
  has_context 'taggable'

  context 'table structure' do
    it { is_expected.to have_db_column(:customisation).of_type(:string) }
    it { is_expected.to have_db_column(:price_cents).of_type(:integer) }
    it { is_expected.to have_db_column(:total_cents).of_type(:integer) }
    it { is_expected.to have_db_column(:currency).of_type(:string) }

    it 'should have non nullable column order_id of type bigint' do
      expect(subject).to have_db_column(:order_id)
        .of_type(:integer)
        .with_options(limit: 8, null: false)
    end
    it { is_expected.to have_db_index(:order_id) }
  end

  context 'relationships' do
    it { is_expected.to belong_to(:order).class_name('Order') }
  end

  context 'validations' do
    it { is_expected.to validate_presence_of :order }
    it { is_expected.to validate_presence_of :currency }

    context 'instance validations' do
    end
  end
end
