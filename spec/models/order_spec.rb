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
    it { is_expected.to belong_to :customer }
    it { is_expected.to belong_to :recipient }

    it { is_expected.to have_many :commodity_line_items }
    it { is_expected.to have_many :shipping_line_items }

    it { is_expected.to have_many :order_taxes }
  end

  context 'validations' do
    it { is_expected.to validate_presence_of :weight }

    shared_examples 'a state that requires customer details' do
      it { is_expected.to validate_presence_of :customer }
      it { is_expected.to validate_presence_of :recipient }

      context 'with a person with no address' do
        let(:person) { create(:person) }

        it { is_expected.not_to allow_value(person).for(:customer) }
        it { is_expected.not_to allow_value(person).for(:recipient) }
      end
    end

    shared_examples 'a state that does not require customer details' do
      it { is_expected.not_to validate_presence_of :customer }
      it { is_expected.not_to validate_presence_of :recipient }
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

  describe '#place_order' do
    let(:bag) { create(:shopping_bag) }
    let(:attrs) { { metadata: { Faker::Lorem.word => Faker::Lorem.word } } }

    def items
      Order.last.commodity_line_items
    end

    def run
      Order.create_from_bag(bag, attrs)
    end

    it 'creates the order' do
      expect { run }.to change(Order, :count).by(1)
    end

    it 'returns the order' do
      expect(run).to be_an_instance_of(Order)
    end

    it 'stores the metadata with the order' do
      expect(run).to have_attributes(attrs)
    end

    it 'has the order in `collecting` state' do
      expect(run).to be_collecting
    end

    shared_examples 'ordering a line item' do
      it 'contains the line item' do
        run
        expect(items).to contain_exactly(an_instance_of(CommodityLineItem))
        expect(items.first).to have_attributes(line_item_attrs)
      end
    end

    context 'with a product' do
      let(:product) { create(:product) }
      let(:line_item_attrs) { { product: product, quantity: 1 } }

      before { bag.apply(product_id: product.id, quantity: 1) }

      include_context 'ordering a line item'
    end

    context 'with a product with metadata' do
      let(:product) { create(:product) }

      let(:line_item_attrs) do
        { product: product, quantity: 1, metadata: { 'a' => 'z' } }
      end

      before do
        bag.apply(product_id: product.id, quantity: 1, metadata: { 'a' => 'z' })
      end

      include_context 'ordering a line item'
    end

    context 'with a variant' do
      let(:variant) { create(:variant) }
      let(:line_item_attrs) { { variant: variant, quantity: 1 } }

      before { bag.apply(variant_id: variant.id, quantity: 1) }

      include_context 'ordering a line item'
    end

    context 'with a variant with metadata' do
      let(:variant) { create(:variant) }

      let(:line_item_attrs) do
        { variant: variant, quantity: 1, metadata: { 'a' => 'z' } }
      end

      before do
        bag.apply(variant_id: variant.id, quantity: 1, metadata: { 'a' => 'z' })
      end

      include_context 'ordering a line item'
    end
  end

  describe '#use_billing_details_for_shipping?' do
    let(:person1) { create(:address).person }
    let(:person2) { create(:address).person }
    let(:order) { create(:order) }
    subject { order.use_billing_details_for_shipping? }

    it 'is an alias for use_billing_details_for_shipping (no question mark)' do
      expect(order).to respond_to(:use_billing_details_for_shipping)
      expect(order.use_billing_details_for_shipping)
        .to eq(order.use_billing_details_for_shipping?)
    end

    context 'when the billing contact is the shipping contact' do
      let(:order) { create(:order, customer: person1, recipient: person1) }
      it { is_expected.to be_truthy }
    end

    context 'when the billing contact is different to the shipping contact' do
      let(:order) { create(:order, customer: person1, recipient: person2) }
      it { is_expected.to be_falsey }
    end
  end

  describe 'transient_subtotal' do
    let(:order) { create(:order, :with_cli) }
    subject { order.transient_subtotal }

    it { is_expected.to be > 0 }
    it do
      is_expected.to eq(
        order.commodity_line_items.map { |cli| cli.price * cli.quantity }.sum)
    end
  end

  describe 'transient_subtotal_cents' do
    let(:order) { create(:order, :with_cli) }
    subject { order.transient_subtotal_cents }

    it { is_expected.to be > 0 }
    it do
      is_expected.to eq(
        order.commodity_line_items
          .map { |cli| cli.price.cents * cli.quantity }.sum)
    end
  end

  describe 'transient_weight' do
    let(:order) { create(:order, :with_cli) }
    subject { order.transient_weight }

    before do
      # cheat, this normally comes from the product/variant on assignment
      order.commodity_line_items.map do |cli|
        cli.update(weight: rand(50..2000))
      end
    end

    it { is_expected.to be > 0 }
    it do
      is_expected.to eq(
        order.commodity_line_items.map { |cli| cli.weight * cli.quantity }.sum)
    end
  end

  describe 'transient_shipping_rate_estimate?' do
    subject(:order) { create(:order, :with_cli) }

    it 'is false without a transient_subtotal' do
      order.commodity_line_items.each { |cli| cli.price = 0 }
      expect(subject.transient_shipping_rate_estimate?)
        .to be_falsey
    end

    it 'is false without shipping rate' do
      expect(subject.transient_shipping_rate_estimate?)
        .to be_falsey
    end

    it 'is false without a shipping rate enabled for use in bag shipping' do
      create :shipping_rate
      expect(subject.transient_shipping_rate_estimate?).to be_falsey
    end

    it 'is false without a shipping rate that is enabled' do
      create :shipping_rate, use_as_bag_shipping: true, enabled: false
      expect(subject.transient_shipping_rate_estimate?).to be_falsey
    end

    it 'is false without a subtotal that falls within range' do
      create :shipping_rate, use_as_bag_shipping: true, enabled: true,
                             min_price: subject.transient_subtotal.cents + 1
      expect(subject.transient_shipping_rate_estimate?).to be_falsey
    end

    it 'is false without a weight that falls within range' do
      create :shipping_rate, use_as_bag_shipping: true, enabled: true,
                             min_weight: subject.transient_weight + 1
      expect(subject.transient_shipping_rate_estimate?).to be_falsey
    end

    it 'is false without a subtotal or weight that falls within range' do
      create :shipping_rate, use_as_bag_shipping: true, enabled: true,
                             min_price: subject.transient_subtotal_cents + 1,
                             min_weight: subject.transient_weight + 1
      expect(subject.transient_shipping_rate_estimate?).to be_falsey
    end

    it 'is true when a matching shipping rate is found' do
      create :shipping_rate, use_as_bag_shipping: true, enabled: true
      expect(subject.transient_shipping_rate_estimate?).to be_truthy
    end

    it 'is true when multiple shipping rates are found' do
      create :shipping_rate, use_as_bag_shipping: true, enabled: true
      create :shipping_rate, use_as_bag_shipping: true, enabled: true

      expect(subject.transient_shipping_rate_estimate?).to be_truthy
    end
  end

  describe 'transient_shipping_rate_estimate' do
    subject(:order) { create(:order, :with_cli) }

    it 'is false without a transient_subtotal' do
      order.commodity_line_items.each { |cli| cli.price = 0 }
      expect(subject.transient_shipping_rate_estimate)
        .to be_nil
    end

    it 'is false without shipping rate' do
      expect(subject.transient_shipping_rate_estimate)
        .to be_nil
    end

    it 'is false without a shipping rate enabled for use in bag shipping' do
      create :shipping_rate
      expect(subject.transient_shipping_rate_estimate).to be_nil
    end

    it 'is false without a shipping rate that is enabled' do
      create :shipping_rate, use_as_bag_shipping: true, enabled: false
      expect(subject.transient_shipping_rate_estimate).to be_nil
    end

    it 'is false without a subtotal that falls within range' do
      create :shipping_rate, use_as_bag_shipping: true, enabled: true,
                             min_price: subject.transient_subtotal.cents + 1
      expect(subject.transient_shipping_rate_estimate).to be_nil
    end

    it 'is false without a weight that falls within range' do
      create :shipping_rate, use_as_bag_shipping: true, enabled: true,
                             min_weight: subject.transient_weight + 1
      expect(subject.transient_shipping_rate_estimate).to be_nil
    end

    it 'is false without a subtotal or weight that falls within range' do
      create :shipping_rate, use_as_bag_shipping: true, enabled: true,
                             min_price: subject.transient_subtotal_cents + 1,
                             min_weight: subject.transient_weight + 1
      expect(subject.transient_shipping_rate_estimate).to be_nil
    end

    it 'is true when a matching shipping rate is found' do
      sr = create :shipping_rate, use_as_bag_shipping: true, enabled: true
      expect(subject.transient_shipping_rate_estimate).to eq(sr)
    end

    it 'is true when multiple shipping rates are found' do
      sr = create :shipping_rate, use_as_bag_shipping: true, enabled: true
      create :shipping_rate, use_as_bag_shipping: true, enabled: true

      expect(subject.transient_shipping_rate_estimate).to eq(sr)
    end
  end

  describe '#transient_total' do
    subject(:order) { create(:order, :with_cli) }

    context 'without shipping rate' do
      it 'is equivalent to transient_subtotal' do
        expect(subject.transient_total).to eq(subject.transient_subtotal)
      end
    end

    context 'with shipping rate' do
      let!(:sr) do
        create(:shipping_rate, :with_regions,
               use_as_bag_shipping: true, enabled: true)
      end

      it 'has a shipping rate with cost' do
        expect(sr.shipping_rate_regions.first.price).to be > 0
      end

      it 'is equivalent to transient_subtotal + shipping rate price' do
        expect(subject.transient_total)
          .to eq(subject.transient_subtotal +
                 sr.shipping_rate_regions.first.price)
      end
    end
  end
end
