require 'rails_helper'

RSpec.describe LineItem, type: :model, site_scoped: true do
  has_context 'parent site' do
    let(:factory) { :product_line_item }
  end
  has_context 'parent site' do
    let(:factory) { :variant_line_item }
  end
  has_context 'item reference' do
    let(:factory) { :line_item }
  end

  has_context 'versioned'

  has_context 'monies', :line_item,
              [{ field: :price, calculated: false },
               { field: :total, calculated: true }]

  has_context 'metadata'
  has_context 'taggable'

  context 'table structure' do
    it { is_expected.to have_db_column(:customisation).of_type(:string) }
    it { is_expected.to have_db_column(:price_cents).of_type(:integer) }
    it { is_expected.to have_db_column(:total_cents).of_type(:integer) }
    it { is_expected.to have_db_column(:currency).of_type(:string) }
    it { is_expected.to have_db_column(:quantity).of_type(:integer) }

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
    it { is_expected.to validate_presence_of :quantity }
    it { is_expected.to validate_presence_of :currency }

    context 'instance validations' do
    end
  end

  describe '#total' do
    subject { build :line_item }
    let(:expected_total) { subject.price * subject.quantity }
    it 'represents price * quantity' do
      expect(subject.total).to eq(expected_total)
    end
    it 'has order currency' do
      expect(subject.total.currency).to eq(subject.order.currency)
    end
    it 'is a Money instance' do
      expect(subject.total).to be_a(Money)
    end

    context 'when quantity is modified' do
      def run
        subject.quantity = Faker::Number.number(2)
        subject.save
      end

      it 'total is re-calculated' do
        expect { run }.to change(subject, :total).from(expected_total)
      end
    end

    context 'when price is modified' do
      def run
        subject.price = Faker::Number.number(3).to_i + 5
        subject.save
      end

      it 'total is re-calculated' do
        expect { run }.to change(subject, :total).from(expected_total)
      end
    end
  end

  describe '#quantity=' do
    let(:line_item) { build :line_item }
    let(:new_quantity) { Faker::Number.number(3).to_i + 1 }
    let(:new_total) { line_item.price * new_quantity }
    def run
      line_item.quantity = new_quantity
    end

    subject { -> { run } }
    it { is_expected.to change(line_item, :quantity).to eq(new_quantity) }
    it { is_expected.to change(line_item, :total).to eq(new_total) }
  end

  describe '#price=' do
    let(:line_item) { build :line_item }
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
