require 'rails_helper'

RSpec.describe Variant, type: :model do
  has_context 'specification'
  has_context 'metadata'

  context 'table structure' do
    it { is_expected.to have_db_column(:description).of_type(:text)  }
    it { is_expected.to have_db_column(:gtin).of_type(:string)  }
    it { is_expected.to have_db_column(:sku).of_type(:string) }
    it { is_expected.to have_db_column(:grams).of_type(:integer) }
    it { is_expected.to have_db_column(:price_cents).of_type(:integer) }
  end

  context 'relationships' do
    it { is_expected.to belong_to :product }
    it { is_expected.to have_many :variation_instances }
    it { is_expected.to have_many :variations }
    it { is_expected.to have_many :traits }
    it { is_expected.to have_one :inventory }
  end

  context 'validations' do
    subject { create :variant }
    it { is_expected.to validate_presence_of :product }
    it { is_expected.to validate_presence_of :variation_instances }
    it { is_expected.to validate_presence_of :inventory }
  end

  context 'localized attributes' do
    subject { create :variant }

    describe '#price' do
      context 'not locally defined' do
        it 'has no local price' do
          expect(subject.varied_price).to be_nil
        end
        it 'uses the products price' do
          expect(subject.price).to eq(subject.product.price)
        end
      end

      context 'locally defined' do
        let(:local_price) { Money.new(Faker::Number.number(4)) }
        subject { create :variant, price: local_price }

        it 'does not use the products price' do
          expect(subject.price).to_not eq(subject.product.price)
        end
        it 'uses the local price' do
          expect(subject.price).to eq(local_price)
        end
      end
    end

    specifications = { 'categories' => [{ 'name' => 'cat1',
                                          'values' => [{ 'name' => 'val1',
                                                         'value' => 'val' }]
                                        }] }
    localized_attributes = { description: Faker::Lorem.sentence,
                             gtin: Faker::Number.number(10),
                             sku: Faker::Number.number(10),
                             grams: Faker::Number.number(4).to_i,
                             specifications: specifications }

    localized_attributes.each do |k, v|
      describe "##{k}" do
        context 'not locally defined' do
          before { subject.product.update(localized_attributes) }
          it "has no local #{k}" do
            expect(subject[k.to_sym]).to be_nil
          end
          it "uses the products #{k}" do
            expect(subject.send(k)).to eq(subject.product.send(k))
          end
          it 'has the expected value' do
            expect(subject.product.send(k)).to eq(v)
          end
        end
        context 'locally defined' do
          before { subject.update(localized_attributes) }
          it "does not use the products #{k}" do
            expect(subject.send(k)).to_not eq(subject.product.send(k))
          end
          it "uses the local #{k}" do
            expect(subject.send(k)).to eq(subject[k.to_sym])
          end
          it 'has the expected value' do
            expect(subject.send(k)).to eq(v)
          end
        end
      end
    end
  end
end
