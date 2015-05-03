require 'rails_helper'

RSpec.shared_examples 'line item' do |line_item_factory|
  has_context 'parent site'do
    let(:factory) { line_item_factory }
  end

  has_context 'versioned'

  has_context 'monies', line_item_factory,
              [{ field: :price, calculated: false },
               { field: :total, calculated: true },
               { field: :tax, calculated: true }]

  has_context 'metadata'
  has_context 'taggable'

  context 'table structure' do
    it { is_expected.to have_db_column(:customisation).of_type(:string) }
    it { is_expected.to have_db_column(:price_cents).of_type(:integer) }
    it { is_expected.to have_db_column(:total_cents).of_type(:integer) }
    it { is_expected.to have_db_column(:currency).of_type(:string) }
    it do
      is_expected.to have_db_column(:quantity).of_type(:integer)
        .with_options(default: 0, allow_nil: true)
    end
    it do
      is_expected.to have_db_column(:weight).of_type(:integer)
        .with_options(default: 0, allow_nil: true)
    end
    it do
      is_expected.to have_db_column(:total_weight).of_type(:integer)
        .with_options(default: 0, allow_nil: true)
    end

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

  describe '#price=' do
    let(:line_item) { build :commodity_line_item }
    let(:new_price) { Faker::Number.number(4).to_i }
    let(:new_price_money) do
      Money.new(new_price, line_item.site.currency)
    end
    let(:new_total) { new_price * line_item.quantity }
    let(:new_total_money) do
      Money.new(new_total, line_item.site.currency)
    end
    def run
      line_item.price = new_price
    end

    subject { -> { run } }
    it { is_expected.to change(line_item, :price).to eq(new_price_money) }
    it { is_expected.to change(line_item, :total).to eq(new_total_money) }
  end
end
