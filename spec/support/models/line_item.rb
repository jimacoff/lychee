require 'rails_helper'

RSpec.shared_examples 'line item' do
  include_context 'parent site'

  has_context 'versioned'

  has_context 'monies', :base_line_item,
              [{ field: :price, calculated: false },
               { field: :subtotal, calculated: true },
               { field: :total, calculated: true },
               { field: :tax, calculated: true }]

  has_context 'metadata'
  has_context 'taggable'

  context 'table structure' do
    it { is_expected.to have_db_column(:customisation).of_type(:string) }
    it { is_expected.to have_db_column(:price_cents).of_type(:integer) }
    it { is_expected.to have_db_column(:total_cents).of_type(:integer) }
    it { is_expected.to have_db_column(:currency).of_type(:string) }
    it { is_expected.to have_db_column(:total_tax_rate).of_type(:decimal) }

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
    it { is_expected.to have_many :line_item_taxes }
    it { is_expected.to have_many(:tax_rates).through(:line_item_taxes) }
  end

  context 'validations' do
    it { is_expected.to validate_presence_of :order }
    it { is_expected.to validate_presence_of :currency }

    context 'instance validations' do
      subject { create factory }

      context 'total_tax_rate' do
        it 'must be greater that or equal to 0' do
          expect(subject).to validate_numericality_of(:total_tax_rate)
            .is_greater_than_or_equal_to(0.0)
        end
        it 'must be less than or equal to 0' do
          expect(subject).to validate_numericality_of(:total_tax_rate)
            .is_less_than_or_equal_to(1.0)
        end
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
  end

  describe '#calculate_total' do
    let!(:tr1) do
      create :tax_rate, tax_category: Site.current.primary_tax_category,
                        rate: 0.5
    end
    let(:delivery_address) { create :address, country: tr1.country }
    let(:order) { create :order, delivery_address: delivery_address }
    let(:owner_instance) { create owner_factory }
    subject { create factory, order: order }

    before do
      subject.send("#{owner}=", owner_instance)
    end

    context 'preconditions' do
      it 'fails when self is invalid' do
        subject.currency = nil
        expect { subject.calculate_total }
          .to raise_error('attempt to calculate total with invalid state')
      end

      it 'fails when order is invalid' do
        subject.order.weight = nil
        expect { subject.calculate_total }
          .to raise_error('attempt to calculate total with invalid state')
      end

      it 'fails when order is nil' do
        subject.order = nil
        expect { subject.calculate_total }
          .to raise_error('attempt to calculate total with invalid state')
      end
    end

    context 'subtotal' do
      it 'stores the expected value' do
        expect { subject.calculate_total }.to change(subject, :subtotal)
          .to eq(expected_subtotal)
      end
    end

    context 'tax_rates' do
      context 'when no rates apply' do
        let(:delivery_address) { create :address, country: create(:country) }
        before { subject.calculate_total }

        it 'stores no tax rate references' do
          expect(subject.tax_rates).to be_empty
        end

        it 'has a 0 tax rate' do
          expect(subject.total_tax_rate).to eq(0.0)
        end
      end

      context 'when a single rate applies' do
        before { subject.calculate_total }

        it 'stores a tax rate reference' do
          expect(subject.tax_rates).to include(tr1)
        end

        it 'has a total tax rate of the single included rate' do
          expect(subject.total_tax_rate).to eq(tr1.rate)
        end
      end

      context 'tax rates are based on Site preference' do
        let!(:tr1) do
          create :tax_rate, tax_category: Site.current.primary_tax_category,
                            rate: 0.1, priority: 1
        end
        let!(:tr2) do
          create :tax_rate, tax_category: Site.current.primary_tax_category,
                            rate: 0.2, priority: 2
        end
        let!(:tr3) do
          create :tax_rate, tax_category: Site.current.primary_tax_category,
                            rate: 0.3, priority: 3
        end
        let(:delivery_address) do
          create :address, country: tr1.country
        end
        let(:customer_address) do
          create :address, country: tr2.country
        end
        let(:subscriber_address) do
          create :address, country: tr3.country
        end
        let(:order) do
          create :order, delivery_address: delivery_address,
                         customer_address: customer_address
        end

        before do
          Site.current.subscriber_address.delete
          Site.current.subscriber_address = subscriber_address
          Site.current.save
        end
        after do
          Site.current.preferences.tax_basis = :delivery
          Site.current.preferences.save
        end

        context 'delivery address as tax_basis' do
          before { subject.calculate_total }
          it 'gets taxes matching delivery geographic location' do
            expect(subject.tax_rates).to include(tr1)
          end
        end

        context 'customer address as tax_basis' do
          before do
            Site.current.preferences.tax_basis = :customer
            Site.current.preferences.save
            subject.calculate_total
          end
          it 'gets taxes matching customer geographic location' do
            expect(subject.tax_rates).to include(tr2)
          end
        end

        context 'subscriber address as tax_basis' do
          before do
            Site.current.preferences.tax_basis = :subscriber
            Site.current.preferences.save
            subject.calculate_total
          end
          it 'gets taxes matching subscriber geographic location' do
            expect(subject.tax_rates).to include(tr3)
          end
        end
      end

      context 'when multiple tax rates apply' do
        let!(:tr2) do
          create :tax_rate, tax_category: Site.current.primary_tax_category,
                            rate: 0.01, country: tr1.country, priority: 2
        end
        let!(:tr3) do
          create :tax_rate, tax_category: Site.current.primary_tax_category,
                            rate: 0.002, country: tr1.country, priority: 3
        end
        let!(:tr4) do # must not apply, not geographically valid
          create :tax_rate, tax_category: Site.current.primary_tax_category,
                            rate: 0.9, country: create(:country), priority: 99
        end
        let(:expected_tax_rate) { tr1.rate + tr2.rate + tr3.rate }

        before { subject.calculate_total }

        it 'stores all tax rate references' do
          expect(subject.tax_rates).to include(tr1, tr2, tr3)
        end

        it 'has a total tax rate of combined, applicable rates' do
          expect(subject.total_tax_rate).to eq(expected_tax_rate)
        end
      end

      context 'when overridden tax rates apply' do
        context 'single override' do
          let!(:tr2) do
            create :tax_rate, tax_category: Site.current.primary_tax_category,
                              rate: 0.01, country: tr1.country, priority: 2
          end
          let!(:tr3) do
            create :tax_rate, tax_category: Site.current.primary_tax_category,
                              rate: 0.002, country: tr1.country, priority: 3
          end

          let(:overridden_tax_category) { create :tax_category }
          let(:owner_instance) do
            create owner_factory, tax_override: overridden_tax_category
          end

          let!(:tr2_over) do
            create :tax_rate, tax_category: overridden_tax_category,
                              rate: 0.0001, country: tr1.country, priority: 2
          end

          let(:expected_tax_rate) { tr1.rate + tr2_over.rate + tr3.rate }

          before { subject.calculate_total }

          it 'stores all tax rate references' do
            expect(subject.tax_rates).to include(tr1, tr2_over, tr3)
          end

          it 'has a total tax rate of combined, applicable rates' do
            expect(subject.total_tax_rate).to eq(expected_tax_rate)
          end
        end

        context 'multiple overrides' do
          let!(:tr2) do
            create :tax_rate, tax_category: Site.current.primary_tax_category,
                              rate: 0.01, country: tr1.country, priority: 2
          end
          let!(:tr3) do
            create :tax_rate, tax_category: Site.current.primary_tax_category,
                              rate: 0.002, country: tr1.country, priority: 3
          end

          let(:overridden_tax_category) { create :tax_category }
          let(:owner_instance) do
            create owner_factory, tax_override: overridden_tax_category
          end

          let!(:tr2_over) do
            create :tax_rate, tax_category: overridden_tax_category,
                              rate: 0.0001, country: tr1.country, priority: 2
          end
          let!(:tr3_over) do
            create :tax_rate, tax_category: overridden_tax_category,
                              rate: 0.0002, country: tr1.country, priority: 3
          end

          let(:expected_tax_rate) { tr1.rate + tr2_over.rate + tr3_over.rate }

          before { subject.calculate_total }

          it 'stores all tax rate references' do
            expect(subject.tax_rates).to include(tr1, tr2_over, tr3_over)
          end

          it 'has a total tax rate of combined, applicable rates' do
            expect(subject.total_tax_rate).to eq(expected_tax_rate)
          end
        end
      end
    end

    context 'tax' do
      context 'prices exclusive of tax' do
        let(:expected_tax) { subject.subtotal * subject.total_tax_rate }
        before { subject.calculate_total }

        it 'stores the expected value' do
          expect(subject.tax).to eq(expected_tax)
        end
      end
      context 'prices inclusive of tax' do
        let(:expected_tax) { subject.subtotal / (1 + subject.total_tax_rate) }
        before do
          Site.current.preferences.prices_include_tax = true
          Site.current.preferences.save
          subject.calculate_total
        end

        after do
          Site.current.preferences.prices_include_tax = false
          Site.current.preferences.save
        end

        it 'stores the expected value' do
          expect(subject.tax).to eq(expected_tax)
        end
      end
    end

    context 'final total' do
      context 'prices exclusive of tax' do
        let(:expected_total) do
          subject.subtotal + subject.subtotal * subject.total_tax_rate
        end
        before { subject.calculate_total }

        it 'stores the expected value' do
          expect(subject.total).to eq(expected_total)
        end
      end
      context 'prices inclusive of tax' do
        before do
          Site.current.preferences.prices_include_tax = true
          Site.current.preferences.save
          subject.calculate_total
        end

        after do
          Site.current.preferences.prices_include_tax = false
          Site.current.preferences.save
        end

        it 'stores the expected value' do
          expect(subject.total).to eq(subject.subtotal)
        end
      end
    end
  end
end
