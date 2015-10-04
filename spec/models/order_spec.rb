require 'rails_helper'

RSpec.describe Order, type: :model, site_scoped: true do
  has_context 'parent site' do
    let(:factory) { :order }
  end
  has_context 'monies', :order,
              [{ field: :subtotal, calculated: true, allow_nil: true },
               { field: :total_commodities, calculated: true },
               { field: :total_shipping, calculated: true },
               { field: :total_tax, calculated: true },
               { field: :total, calculated: true }]
  has_context 'versioned'
  has_context 'metadata'
  has_context 'taggable'

  context 'table structure' do
    it { is_expected.to have_db_column(:weight).of_type(:integer) }
  end

  context 'relationships' do
    it { is_expected.to belong_to :customer_address }
    it { is_expected.to belong_to :delivery_address }

    it { is_expected.to have_many :commodity_line_items }
    it { is_expected.to have_many :shipping_line_items }

    it { is_expected.to have_many :order_taxes }
  end

  context 'validations' do
    it { is_expected.to validate_presence_of :weight }

    shared_examples 'a state that requires customer details' do
      it { is_expected.to validate_presence_of :customer_address }
      it { is_expected.to validate_presence_of :delivery_address }
    end

    shared_examples 'a state that does not require customer details' do
      it { is_expected.not_to validate_presence_of :customer_address }
      it { is_expected.not_to validate_presence_of :delivery_address }
    end

    no_customer_info_states = %i(new collecting cancelled abandoned)

    no_customer_info_states.each do |state|
      context "when #{state}" do
        subject { create(:order, workflow_state: state) }
        it_behaves_like 'a state that does not require customer details'
      end
    end

    (Order.workflow_spec.states.keys - no_customer_info_states).each do |state|
      context "when #{state}" do
        subject { create(:order, workflow_state: state) }
        it_behaves_like 'a state that requires customer details'
      end
    end
  end

  describe '#calculate_subtotal' do
    let(:order) { create :order, commodity_line_items: commodity_line_items }
    let(:commodity_line_items) do
      create_list(:commodity_line_item, 3, :with_product,
                  quantity: Faker::Number.number(3))
    end
    let!(:tax_rate) do
      create :tax_rate, country: order.delivery_address.country,
                        tax_category: Site.current.primary_tax_category
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
      context 'when subtotal should include tax' do
        let(:items_total) { commodity_line_items.sum(&:total).cents }
        subject { -> { order.calculate_subtotal } }

        before do
          Site.current.preferences.order_subtotal_include_tax = true
          Site.current.preferences.save
          commodity_line_items.each(&:calculate_total)
        end

        after do
          Site.current.preferences.order_subtotal_include_tax = true
          Site.current.preferences.save
        end

        it do
          is_expected.to change(order, :subtotal_cents)
            .from(0).to eq(items_total)
        end

        it 'has site currency' do
          expect(order.subtotal.currency).to eq(Site.current.currency)
        end

        it 'is a Money instance' do
          expect(order.subtotal).to be_a(Money)
        end
      end

      context 'when subtotal should not include tax' do
        let(:items_total) { commodity_line_items.sum(&:subtotal).cents }
        subject { -> { order.calculate_subtotal } }

        before do
          Site.current.preferences.order_subtotal_include_tax = false
          Site.current.preferences.save
          commodity_line_items.each(&:calculate_total)
        end

        after do
          Site.current.preferences.order_subtotal_include_tax = true
          Site.current.preferences.save
        end

        it do
          is_expected.to change(order, :subtotal_cents)
            .from(0).to eq(items_total)
        end

        it 'has site currency' do
          expect(order.subtotal.currency).to eq(Site.current.currency)
        end

        it 'is a Money instance' do
          expect(order.subtotal).to be_a(Money)
        end
      end
    end
  end

  describe '#calculate_tax_rates' do
    let(:order) do
      create :order
    end
    let(:shipping_line_item) do
      create :shipping_line_item
    end
    let(:commodity_line_items) do
      create_list(:commodity_line_item, 3, :with_product,
                  quantity: Faker::Number.number(3))
    end

    context 'without applicable tax_rates' do
      let!(:tax_rate) do
        create :tax_rate, tax_category: Site.current.primary_tax_category,
                          rate: 0.2, priority: 1
      end

      before do
        order.commodity_line_items << commodity_line_items
        order.shipping_line_items << shipping_line_item

        commodity_line_items.each(&:calculate_total)
        shipping_line_item.calculate_total

        order.calculate_total
      end

      context 'tax_rate_totals' do
        it 'is expected to have 0 rates' do
          expect(order.order_taxes.size).to eq(0)
        end
        it 'is expected to have a zero total' do
          tax_rates_total = order.order_taxes.map(&:tax_amount).sum
          expect(tax_rates_total).to eq(0)
        end
      end
    end

    context 'with applicable tax_rates' do
      let!(:tax_rate) do
        create :tax_rate, country: order.delivery_address.country,
                          tax_category: Site.current.primary_tax_category,
                          rate: 0.2, priority: 1
      end
      let!(:tax_rate2) do
        create :tax_rate, country: order.delivery_address.country,
                          tax_category: Site.current.primary_tax_category,
                          rate: 0.3, priority: 2
      end
      let!(:tax_rate3) do # should be unused
        create :tax_rate, tax_category: Site.current.primary_tax_category,
                          rate: 0.4, priority: 2
      end

      before do
        order.commodity_line_items << commodity_line_items
        order.shipping_line_items << shipping_line_item

        commodity_line_items.each(&:calculate_total)
        shipping_line_item.calculate_total

        order.calculate_total
      end

      context 'tax_rate_totals' do
        it 'is expected to have 2 rates' do
          expect(order.order_taxes.size).to eq(2)
        end
        it 'is expected to have a total equal to order tax' do
          tax_rates_total = order.order_taxes.map(&:tax_amount).sum
          expect(tax_rates_total).to eq(order.total_tax)
        end
      end
    end
  end

  describe '#calculate_total' do
    context 'must be in vaild state' do
      subject { create :order }
      it 'is invalid with commodities but no shipping' do
        create :commodity_line_item, :with_product, order: subject
        expect { subject.calculate_total }
          .to raise_error('attempt to calculate total with invalid state')
      end
      it 'is invalid with shipping but no commodities' do
        create :shipping_line_item, order: subject
        expect { subject.calculate_total }
          .to raise_error('attempt to calculate total with invalid state')
      end
      it 'is valid with shipping and commodities' do
        create :commodity_line_item, :with_product, order: subject
        create :shipping_line_item, order: subject
        expect { subject.calculate_total }.not_to raise_error
      end
    end

    context 'when order is complete' do
      let!(:commodity_line_items) do
        create_list(:commodity_line_item, 3, :with_product, order: subject)
      end
      let!(:shipping_line_item) { create :shipping_line_item, order: subject }
      let(:items_total) { commodity_line_items.sum(&:total).cents }

      subject { create :order }

      before do
        commodity_line_items.each(&:calculate_total)
        commodity_line_items.each(&:save)
        shipping_line_item.calculate_total
        shipping_line_item.save

        subject.calculate_total
      end

      it 'sets total to combined commodities and shipping incl tax' do
        expect(subject.total.cents)
          .to eq(items_total + shipping_line_item.price.cents)
      end

      it 'sets total_commodities to sum of all commodities incl tax' do
        expect(subject.total_commodities)
          .to eq(commodity_line_items.sum(&:total))
      end

      it 'sets total_shipping to sum of all shipping incl tax' do
        expect(subject.total_shipping)
          .to eq(shipping_line_item.total)
      end

      it 'sets tax to total tax of all commodities and shipping' do
        expect(subject.total_tax)
          .to eq(shipping_line_item.tax +
                 commodity_line_items.sum(&:tax))
      end
    end
  end

  describe '#calculate_weight' do
    let(:order) { create :order, commodity_line_items: commodity_line_items }
    let(:commodity_line_items) do
      create_list(:commodity_line_item, 3, :with_product,
                  weight: Faker::Number.number(4).to_i)
    end

    before do
      commodity_line_items.each(&:calculate_total_weight)
    end

    context 'without commodity_line_items present' do
      let!(:initial_weight) { order.calculate_weight }

      def run
        order.commodity_line_items.destroy_all
        order.calculate_weight
      end

      subject { -> { run } }
      it do
        is_expected.to change(order, :weight)
          .from(initial_weight).to eq(0)
      end
    end

    context 'totals weight of all commodity_line_items' do
      let(:items_weight) do
        commodity_line_items.map { |cli| cli.weight * cli.quantity }.sum
      end
      subject { -> { order.calculate_weight } }
      it { is_expected.to change(order, :weight).from(0).to eq(items_weight) }
    end
  end

  describe 'workflow' do
    subject { create(:order) }

    it_behaves_like 'workflow object', transitions: [], state: :new

    # From :new
    it_behaves_like 'workflow object', transitions: %i(submit),
                                       state: :collecting

    # From :collecting
    it_behaves_like 'workflow object', transitions: %i(submit calculate),
                                       state: :pending
    it_behaves_like 'workflow object', transitions: %i(submit cancel),
                                       state: :cancelled
    it_behaves_like 'workflow object', transitions: %i(submit abandon),
                                       state: :abandoned

    # From :pending
    it_behaves_like 'workflow object',
                    transitions: %i(submit calculate confirm),
                    state: :confirmed
    it_behaves_like 'workflow object',
                    transitions: %i(submit calculate cancel),
                    state: :cancelled
    it_behaves_like 'workflow object',
                    transitions: %i(submit calculate abandon),
                    state: :abandoned

    # From :confirmed
    it_behaves_like 'workflow object',
                    transitions: %i(submit calculate confirm pay),
                    state: :paid
    it_behaves_like 'workflow object',
                    transitions: %i(submit calculate confirm cancel),
                    state: :cancelled
    it_behaves_like 'workflow object',
                    transitions: %i(submit calculate confirm abandon),
                    state: :abandoned

    context 'when paid' do
      before do
        %i(submit calculate confirm pay).each { |s| subject.send(:"#{s}!") }
      end

      # From :paid
      it_behaves_like 'workflow object', transitions: %i(accept),
                                         state: :accepted
      it_behaves_like 'workflow object', transitions: %i(hold),
                                         state: :on_hold

      # From :accepted
      it_behaves_like 'workflow object', transitions: %i(accept hold),
                                         state: :on_hold
      it_behaves_like 'workflow object', transitions: %i(accept ship),
                                         state: :shipped

      # From :on_hold
      it_behaves_like 'workflow object', transitions: %i(hold accept),
                                         state: :accepted
      it_behaves_like 'workflow object', transitions: %i(hold reject),
                                         state: :rejected

      # From :shipped
      it_behaves_like 'workflow object', transitions: %i(accept ship adjust),
                                         state: :adjusted
      it_behaves_like 'workflow object', transitions: %i(accept ship refund),
                                         state: :refunded

      # From :adjusted
      it_behaves_like 'workflow object',
                      transitions: %i(accept ship adjust refund),
                      state: :refunded

      # From :rejected
      it_behaves_like 'workflow object',
                      transitions: %i(hold reject refund),
                      state: :refunded
    end
  end
end
