require 'rails_helper'

RSpec.describe Variant, type: :model do
  has_context 'specification'
  has_context 'metadata'

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
      let(:trait) { create :trait }
      let(:trait_value) { Faker::Lorem.word }

      def run
        subject.add_trait(trait.id, trait_value)
      end

      it 'adds the specified trait id and value' do
        expect { run }.to change { subject.traits.count }.by 1
      end

      it 'has #changed?' do
        expect { run }.to change(subject, :traits_changed?).to true
      end

      it 'is valid' do
        run
        expect(subject).to be_valid
      end
    end

    describe '#add_traits' do
      let(:trait) { create :trait }
      let(:trait_value) { Faker::Lorem.word }
      let(:trait2) { create :trait }
      let(:trait2_value) { Faker::Lorem.word }

      let(:traits) { { trait.id => trait_value, trait2.id => trait2_value } }

      def run
        subject.add_traits(traits)
      end

      it 'adds the specified traits' do
        expect { run }.to change { subject.traits.count }.by 2
      end

      it 'adds traits uniquely' do
        run
        expect { subject.add_trait(trait.id, 'newval') }.to \
          change { subject.traits }.and \
          change { subject.traits.count }.by 0
      end

      it 'has #changed?' do
        expect { run }.to change(subject, :traits_changed?).to true
      end

      it 'is valid' do
        run
        expect(subject).to be_valid
      end
    end

    describe '#delete_trait' do
      let(:trait) { create :trait }
      let(:trait_value) { Faker::Lorem.word }

      before :each do
        subject.traits[trait.id] = trait_value
        expect(subject.traits[trait.id]).not_to be_nil
      end

      def run
        subject.delete_trait(trait.id)
      end

      it 'deletes a trait' do
        expect { run }.to change { subject.traits.count }.by(-1)
      end

      it 'deletes the specified trait' do
        run
        expect(subject.traits[trait.id]).to be_nil
      end

      it 'has #changed?' do
        expect { run }.to change(subject, :traits_changed?).to true
      end

      it 'is valid' do
        run
        expect(subject).to be_valid
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

    @specifications = { categories: [{ name: 'cat1',
                                       values: [{ name: 'val1',
                                                  value: 'val' }] }] }
    @overloaded_attributes = { description: Faker::Lorem.sentence,
                               gtin: Faker::Number.number(10),
                               sku: Faker::Number.number(10),
                               grams: Faker::Number.number(5),
                               specifications: @specifications }
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
          subject { build :variant, "#{k}" => v }
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
