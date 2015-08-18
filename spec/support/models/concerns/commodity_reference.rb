RSpec.shared_examples 'commodity reference' do
  context 'table structure' do
    it 'should have non nullable column product_id of type bigint' do
      expect(subject).to have_db_column(:product_id)
        .of_type(:integer)
        .with_options(limit: 8, null: true)
    end
    it { is_expected.to have_db_index(:product_id) }

    it 'should have non nullable column variant_id of type bigint' do
      expect(subject).to have_db_column(:variant_id)
        .of_type(:integer)
        .with_options(limit: 8, null: true)
    end
    it { is_expected.to have_db_index(:variant_id) }
  end

  context 'relationships' do
    it { is_expected.to belong_to(:product).class_name('Product') }
    it { is_expected.to belong_to(:variant).class_name('Variant') }
  end

  context 'validations' do
    context 'instance validations' do
      let(:product) { create(:product) }
      let(:variant) { create(:variant, product: product) }

      context 'both product and variant specified' do
        subject { build factory, product: product, variant: variant }
        it { is_expected.to be_invalid }
      end

      context 'neither product nor variant specified' do
        subject { build factory }
        it { is_expected.to be_invalid }
      end

      context 'only product specified' do
        subject { create(factory, product: product) }
        it { is_expected.to be_valid }
      end

      context 'only variant specified' do
        subject { create(factory, variant: variant) }
        it { is_expected.to be_valid }
      end
    end
  end

  describe '#commodity' do
    let(:product) { create(:product) }
    let(:variant) { create(:variant, product: product) }

    context 'product specified' do
      subject { build(factory, product: product) }
      it 'returns the product' do
        expect(subject.commodity).to eq(product)
      end
    end

    context 'variant specified' do
      subject { build(factory, variant: variant) }
      it 'returns the variant' do
        expect(subject.commodity).to eq(variant)
      end
    end
  end
end
