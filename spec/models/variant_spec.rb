require 'rails_helper'

RSpec.describe Variant, type: :model do
  it { is_expected.to validate_presence_of :product }

  context 'traits' do
    subject { create :variant }

    it 'must exhibit at least one trait' do
      subject.traits = nil
      expect(subject).not_to be_valid
    end

    it 'must only exhibit registered traits' do
      subject.add_trait('invalid_id', Faker::Lorem.word)
      expect(subject).not_to be_valid
    end

    it 'stores multiple traits' do
      expect(subject).to be_valid
    end

    describe '#add_trait' do
      let(:trait_id) { Faker::Number.number(3) }
      let(:trait_value) { Faker::Lorem.word }

      def run
        subject.add_trait(trait_id, trait_value)
      end

      it 'adds the specified trait id and value' do
        expect { run }.to change { subject.traits.count }.by 1
      end

      it 'has #changed?' do
        expect { run }.to change(subject, :traits_changed?).to true
      end
    end

    describe '#add_traits' do
      let(:trait_id) { Faker::Number.number(3) }
      let(:trait_value) { Faker::Lorem.word }
      let(:trait_id2) { Faker::Number.number(3) }
      let(:trait_value2) { Faker::Lorem.word }

      let(:traits) { { trait_id => trait_value, trait_id2 => trait_value2 } }

      def run
        subject.add_traits(traits)
      end

      it 'adds the specified traits' do
        expect { run }.to change { subject.traits.count }.by 2
      end

      it 'adds traits uniquely' do
        run
        expect { subject.add_trait(trait_id, 'newval') }.to \
          change { subject.traits }.and \
          change { subject.traits.count }.by 0
      end

      it 'has #changed?' do
        expect { run }.to change(subject, :traits_changed?).to true
      end
    end

    describe '#delete_trait' do
      let(:trait_id) { Faker::Number.number(3) }
      let(:trait_value) { Faker::Lorem.word }

      before :each do
        subject.traits[trait_id] = trait_value
      end

      def run
        subject.delete_trait(trait_id)
      end

      it 'deletes the specified trait id' do
        expect { run }.to change { subject.traits.count }.by(-1)
      end

      it 'has #changed?' do
        expect { run }.to change(subject, :traits_changed?).to true
      end
    end
  end

  context 'potentially overloaded attributes' do
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

    @overloaded_attributes = { description: Faker::Lorem.sentence,
                               gtin: Faker::Number.number(10),
                               sku: Faker::Number.number(10),
                               grams: Faker::Number.number(5),
                               specifications: { 'key' => 'variant_value' } }
    @overloaded_attributes.each do |k, v|
      describe "##{k}" do

        context 'not locally defined' do
          it "has no local #{k}" do
            expect(subject[k.to_sym]).to be_nil
          end
          it "uses the products #{k}" do
            expect(subject.send(k)).to eq(subject.product.send(k))
          end
        end
        context 'locally defined' do
          subject { create :variant, "#{k}" => v }
          it "does not use the products #{k}" do
            expect(subject.send(k)).to_not eq(subject.product.send(k))
          end
          it "uses the local #{k}" do
            expect(subject.send(k)).to eq(subject[k.to_sym])
          end
        end
      end
    end
  end
end
