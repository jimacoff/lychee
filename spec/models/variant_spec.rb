require 'rails_helper'

RSpec.describe Variant, type: :model, site_scoped: true do
  has_context 'parent site' do
    let(:factory) { :variant }
  end

  has_context 'versioned'
  has_context 'specification'
  has_context 'monies', :variant_with_varied_price,
              [{ field: :varied_price, calculated: true }]
  has_context 'enablement' do
    let(:factory) { :variant }
  end
  has_context 'content' do
    let(:factory) { :variant }
  end

  context 'table structure' do
    it { is_expected.to have_db_column(:name).of_type(:string) }
    it { is_expected.to have_db_column(:description).of_type(:text) }
    it { is_expected.to have_db_column(:gtin).of_type(:string) }
    it { is_expected.to have_db_column(:sku).of_type(:string) }
    it { is_expected.to have_db_column(:weight).of_type(:integer) }
    it { is_expected.to have_db_column(:varied_price_cents).of_type(:integer) }
    it { is_expected.to have_db_column(:generated_slug).of_type(:string) }
    it { is_expected.to have_db_column(:specified_slug).of_type(:string) }

    it 'should have non nullable column product_id of type bigint' do
      expect(subject).to have_db_column(:product_id)
        .of_type(:integer)
        .with_options(limit: 8, null: false)
    end
    it { is_expected.to have_db_index(:product_id) }
  end

  context 'relationships' do
    it { is_expected.to belong_to(:product).class_name('Product') }

    it { is_expected.to have_many :variation_instances }
    it { is_expected.to have_many :variations }
    it { is_expected.to have_many :traits }
    it { is_expected.to have_one :inventory }
    it { is_expected.to have_many :category_members }
    it { is_expected.to have_many :categories }
  end

  context 'validations' do
    subject { create :variant }
    it { is_expected.to validate_presence_of :product }
    it { is_expected.to validate_presence_of :variation_instances }
    it { is_expected.to validate_numericality_of :weight }

    context 'instance validations' do
      subject { Variant.create(product: create(:product)) }
      it { is_expected.to validate_presence_of :inventory }
    end
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
        let(:local_price) { Faker::Number.number(4).to_i }
        subject { create :variant, price: local_price }

        it 'does not use the products price' do
          expect(subject.price).to_not eq(subject.product.price)
        end
        it 'uses the local price' do
          expect(subject.price.fractional).to eq(local_price)
        end
        it 'has the sites currency' do
          expect(subject.price.currency).to eq(subject.site.currency)
        end
      end
    end

    specifications = { 'categories' => [{ 'name' => 'cat1',
                                          'values' => [{ 'name' => 'val1',
                                                         'value' => 'val' }]
                                        }] }
    localized_attributes = { name: Faker::Lorem.word,
                             description: Faker::Lorem.sentence,
                             gtin: Faker::Number.number(10),
                             sku: Faker::Number.number(10),
                             weight: Faker::Number.number(4).to_i,
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

  context 'categories' do
    subject { create(:variant, :with_categories) }
    it 'associated two subcategories' do
      expect(subject.categories.size).to eq(2)
    end
    it 'category contains product' do
      expect(subject.categories.first.variants.first).to eq(subject)
    end
  end

  describe '#render' do
    it 'Not implemented. Variants only accessible on product page currently'
  end

  describe '#path' do
    it 'Not implemented. Variants only accessible on product page currently'
  end
end
