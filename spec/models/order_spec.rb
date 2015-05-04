require 'rails_helper'

RSpec.describe Order, type: :model, site_scoped: true do
  has_context 'parent site' do
    let(:factory) { :order }
  end
  has_context 'monies', :order,
              [{ field: :subtotal, calculated: true, allow_nil: true },
               { field: :total, calculated: true }]
  has_context 'versioned'
  has_context 'metadata'
  has_context 'taggable'

  context 'table structure' do
    it { is_expected.to have_db_column(:weight).of_type(:integer) }
    it { is_expected.to have_db_column(:status).of_type(:string) }
  end

  context 'relationships' do
    it { is_expected.to have_one :customer_address }
    it { is_expected.to have_one :delivery_address }
    it { is_expected.to have_many :commodity_line_items }
  end

  context 'validations' do
    it { is_expected.to validate_presence_of :weight }
    it { is_expected.to validate_presence_of :status }
    it { is_expected.to validate_length_of(:status).is_at_most(255) }
    it { is_expected.to validate_presence_of :customer_address }
    it { is_expected.to validate_presence_of :delivery_address }

    context 'instance validations' do
      subject { create :order }
    end
  end

  describe '#calculate_subtotal' do
    let(:order) { create :order, commodity_line_items: commodity_line_items }
    let(:commodity_line_items) do
      create_list(:commodity_line_item, 3, quantity: Faker::Number.number(3))
    end

    context 'without commodity_line_items present' do
      let(:subtotal) { order.calculate_subtotal }

      before { commodity_line_items.map(&:calculate_total) }

      def run
        order.commodity_line_items.destroy_all
        order.calculate_subtotal
      end

      subject { -> { run } }
      it do
        is_expected.to change(order, :subtotal_cents).from(subtotal).to eq(0)
      end
    end

    context 'with commodity_line_items present' do
      let(:items_total) { commodity_line_items.map(&:total).sum.cents }
      subject { -> { order.calculate_subtotal } }

      before { commodity_line_items.map(&:calculate_total) }

      it do
        is_expected.to change(order, :subtotal_cents).from(0).to eq(items_total)
      end

      it 'has site currency' do
        expect(order.subtotal.currency).to eq(Site.current.currency)
      end

      it 'is a Money instance' do
        expect(order.subtotal).to be_a(Money)
      end
    end

    pending 'requires additional specs once order workflow considered'
  end

  describe '#calculate_total' do
    it 'has site currency' do
      expect(subject.calculate_total.currency).to eq(Site.current.currency)
    end

    it 'is a Money instance' do
      expect(subject.calculate_total).to be_a(Money)
    end

    pending 'requires additional specs once order workflow considered'
  end

  describe '#calculate_weight' do
    let(:order) { create :order, commodity_line_items: commodity_line_items }
    let(:commodity_line_items) do
      create_list(:commodity_line_item, 3,
                  weight: Faker::Number.number(4).to_i)
    end
    context 'without commodity_line_items present' do
      let!(:initial_weight) { order.calculate_weight }

      def run
        order.commodity_line_items.destroy_all
        order.calculate_weight
      end

      subject { -> { run } }
      it { is_expected.to change(order, :weight).from(initial_weight).to eq(0) }
    end

    context 'totals weight of all commodity_line_items' do
      let(:items_weight) { commodity_line_items.map(&:weight).sum }
      subject { -> { order.calculate_weight } }
      it { is_expected.to change(order, :weight).from(0).to eq(items_weight) }
    end
  end
end
