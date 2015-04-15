require 'rails_helper'

RSpec.describe CommodityLineItem, type: :model, site_scoped: true do
  has_context 'line item', :commodity_line_item
  has_context 'line item', :commodity_variant_line_item

  has_context 'item reference' do
    let(:factory) { :commodity_line_item }
  end
  has_context 'item reference' do
    let(:factory) { :commodity_variant_line_item }
  end

  context 'table structure' do
    it { is_expected.to have_db_column(:quantity).of_type(:integer) }
  end

  context 'relationships' do
  end

  context 'validations' do
    it { is_expected.to validate_presence_of :quantity }

    context 'instance validations' do
    end
  end

  describe '#total' do
    subject { build :commodity_line_item }
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

  describe '#quantity=' do
    let(:commodity_line_item) { build :commodity_line_item }
    let(:new_qty) { Faker::Number.number(3).to_i + 1 }
    let(:new_total) { commodity_line_item.price * new_qty }
    def run
      commodity_line_item.quantity = new_qty
    end

    subject { -> { run } }
    it { is_expected.to change(commodity_line_item, :quantity).to eq(new_qty) }
    it { is_expected.to change(commodity_line_item, :total).to eq(new_total) }
  end
end
