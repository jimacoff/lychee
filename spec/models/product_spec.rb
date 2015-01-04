require 'rails_helper'

RSpec.describe Product, type: :model do
  has_context 'specification'

  it { is_expected.to validate_presence_of :name }
  it { is_expected.to validate_presence_of :generated_slug }
  it { is_expected.to validate_presence_of :description }

  it { is_expected.to validate_presence_of :price_cents }
  it { is_expected.to validate_presence_of :price_currency }

  it { is_expected.to have_many :variants }
  it { is_expected.to have_db_column(:variations).of_type(:json) }

  context 'slugs' do
    subject { create :product }
    let(:specified_slug) { Faker::Lorem.sentence.to_url }

    context 'generated slug' do
      it 'is generated from name' do
        expect(subject.generated_slug).to eq(subject.name.to_url)
      end
      it 'updates on name change' do
        subject.name = Faker::Lorem.sentence
        expect { subject.save }
          .to change(subject, :generated_slug).to(subject.name.to_url)
      end
    end

    describe '#slug' do
      it 'provides generated_slug by default' do
        expect(subject.slug).to eq(subject.generated_slug)
      end
      it 'provides specified_slug when set' do
        subject.specified_slug = specified_slug
        expect(subject.slug).to eq(subject.specified_slug)
      end
    end

    describe '#slug=' do
      it 'updates the specified_slug' do
        expect { subject.slug = specified_slug }
          .to change(subject, :specified_slug).to(specified_slug)
          .and change(subject, :slug).to(specified_slug)
          .and not_change(subject, :generated_slug)
      end
    end
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
      it 'does per instance currency' do
        aud_subject = create :product, price: Money.new(111, 'AUD')
        subject.price = Money.new(111, 'USD')
        expect(subject.price).not_to eq aud_subject.price
        expect(subject.price.fractional).to eq aud_subject.price.fractional
      end
    end
    describe '#price' do
      it 'returns dollars as BigDecimal' do
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

  context 'variations' do
    subject { create :product }

    it 'is valid without any variations' do
      expect(subject).to be_valid
      expect(subject.variants).to be_empty
    end

    it 'is invalid with variations but no variants' do
      subject.variations = { trait: { id: 1 } }
      expect(subject).not_to be_valid
    end

    it 'is invalid with variants but no variations' do
      subject.variants << (create :variant)
      expect(subject).not_to be_valid
    end
  end
end
