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
    it { is_expected.to have_many :order_lines }
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
    subject { create :order, order_lines: order_lines }
    let(:order_lines) { create_list(:product_order_line, 3) }
    let(:expected_total) { order_lines.map(&:total).sum }

    it 'represents totals of all order lines' do
      expect(subject.calculate_total).to eq(expected_total)
    end

    it 'has site currency' do
      expect(subject.calculate_total.currency).to eq(Site.current.currency)
    end

    it 'is a Money instance' do
      expect(subject.calculate_total).to be_a(Money)
    end

    context 'when an order_line is modified' do
      def run
        subject.order_lines[0].quantity = Faker::Number.number(2)
        subject.order_lines[0].save
      end

      it 'order total is re-calculated' do
        expect { run }.to change(subject, :calculate_total).from(expected_total)
      end
    end

    context 'when an order_line is added' do
      let(:order_line) { create(:product_order_line, order: subject) }
      def run
        subject.order_lines << order_line
      end

      it 're-calculates order total' do
        expect { run }.to change(subject, :calculate_total).from(expected_total)
      end

      it 'increases number of lines in the order' do
        expect { run }.to change(subject.order_lines, :size).by(1)
      end
    end

    context 'when an order_line is removed' do
      def run
        subject.order_lines.destroy(order_lines.last)
      end

      it 're-calculates order total' do
        expect { run }.to change(subject, :calculate_total).from(expected_total)
      end

      it 'decreases number of lines in the order' do
        expect { run }.to change(subject.order_lines, :size).by(-1)
      end
    end
  end
end
