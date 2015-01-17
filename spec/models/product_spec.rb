require 'rails_helper'

RSpec.describe Product, type: :model do
  has_context 'specification'
  has_context 'metadata'
  has_context 'slug' do
    subject { create :product }
  end

  context 'table structure' do
    it { is_expected.to have_db_column(:name).of_type(:string) }
    it { is_expected.to have_db_column(:description).of_type(:text) }
    it { is_expected.to have_db_column(:generated_slug).of_type(:string) }
    it { is_expected.to have_db_column(:specified_slug).of_type(:string) }
    it { is_expected.to have_db_column(:gtin).of_type(:string) }
    it { is_expected.to have_db_column(:sku).of_type(:string) }
    it { is_expected.to have_db_column(:price_cents).of_type(:integer) }
    it { is_expected.to have_db_column(:grams).of_type(:integer) }
    it { is_expected.to have_db_column(:active).of_type(:boolean) }
    it { is_expected.to have_db_column(:not_before).of_type(:datetime) }
    it { is_expected.to have_db_column(:not_after).of_type(:datetime) }
  end

  context 'relationships' do
    it { is_expected.to have_many :variants }
    it { is_expected.to have_many :variations }
    it { is_expected.to have_many :traits }
    it { is_expected.to have_one :inventory }
  end

  context 'validations' do
    it { is_expected.to validate_presence_of :name }
    it { is_expected.to validate_presence_of :description }
    it { is_expected.to validate_presence_of :generated_slug }

    it { is_expected.to validate_presence_of :price_cents }
    it { is_expected.to validate_presence_of :price_currency }

    it { is_expected.to validate_presence_of :inventory }
  end

  context 'pricing' do
    subject { create :product }

    describe '#price=' do
      it 'sets price by decimal' do
        subject.price = 1.11
        expect(subject.price).to eq 1.11
        expect(subject.price.currency).to eq MoneyRails.default_currency
      end
      it 'sets price by Money object' do
        money = Money.new 222
        subject.price = money
        expect(subject.price).to equal money
        expect(subject.price).to eq 2.22
        expect(subject.price.currency).to eq MoneyRails.default_currency
      end
      it 'stores price in cents' do
        subject.price = 1.11
        expect(subject.price_cents).to eq(111)
        expect(subject.price.fractional).to eq(111)
      end
      context 'stores currency' do
        let(:aud_subject) { create :product, price: Money.new(111, 'AUD') }
        before { subject.price = Money.new(111, 'USD') }

        it 'has different currencies per instance' do
          expect(subject.price.currency).not_to eq(aud_subject.price.currency)
        end
        it 'has the same fractional per instance' do
          expect(subject.price.fractional).to eq(aud_subject.price.fractional)
        end
      end
    end
    describe '#price' do
      it 'returns dollars as Money' do
        expect(subject.price).to be_a Money
      end
      # Ensure any future library change doesn't bite us as this got
      # modified between 5.y and 6.y
      it 'returns dollars as BigDecimal' do
        expect(subject.price.dollars).to be_a BigDecimal
      end
      it 'returns amount as BigDecimal' do
        expect(subject.price.dollars).to be_a BigDecimal
      end
    end
  end
end
