require 'rails_helper'

RSpec.describe Order, type: :model, site_scoped: true do
  has_context 'parent site' do
    let(:factory) { :order }
  end
  has_context 'monies', :order, [{ field: :total, calculated: true }]
  has_context 'versioned'
  has_context 'metadata'
  has_context 'taggable'

  context 'table structure' do
    it { is_expected.to have_db_column(:total_cents).of_type(:integer) }
    it { is_expected.to have_db_column(:status).of_type(:string) }
  end

  context 'relationships' do
    it { is_expected.to have_one :customer_address }
    it { is_expected.to have_one :delivery_address }
    it { is_expected.to have_many :line_items }
  end

  context 'validations' do
    it { is_expected.to validate_presence_of :status }
    it { is_expected.to validate_length_of(:status).is_at_most(255) }
    it { is_expected.to validate_presence_of :customer_address }
    it { is_expected.to validate_presence_of :delivery_address }

    context 'instance validations' do
      subject { create :order }
    end
  end

  describe '#calculate_total' do
    # TODO: Taxation and postage
    subject { create :order, line_items: line_items }
    let(:line_items) { create_list(:product_line_item, 3) }
    let(:expected_total) { line_items.map(&:total).sum }

    it 'represents totals of all order lines' do
      expect(subject.calculate_total).to eq(expected_total)
    end

    it 'has site currency' do
      expect(subject.calculate_total.currency).to eq(Site.current.currency)
    end

    it 'is a Money instance' do
      expect(subject.calculate_total).to be_a(Money)
    end

    context 'when an line_item is modified' do
      def run
        subject.line_items[0].quantity = Faker::Number.number(2)
        subject.line_items[0].save
      end

      it 'order total is re-calculated' do
        expect { run }.to change(subject, :calculate_total).from(expected_total)
      end
    end

    context 'when an line_item is added' do
      let(:line_item) { create(:product_line_item, order: subject) }
      def run
        subject.line_items << line_item
      end

      it 're-calculates order total' do
        expect { run }.to change(subject, :calculate_total).from(expected_total)
      end

      it 'increases number of lines in the order' do
        expect { run }.to change(subject.line_items, :size).by(1)
      end
    end

    context 'when an line_item is removed' do
      def run
        subject.line_items.destroy(line_items.last)
      end

      it 're-calculates order total' do
        expect { run }.to change(subject, :calculate_total).from(expected_total)
      end

      it 'decreases number of lines in the order' do
        expect { run }.to change(subject.line_items, :size).by(-1)
      end
    end
  end
end
