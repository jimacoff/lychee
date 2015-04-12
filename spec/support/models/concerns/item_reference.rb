RSpec.shared_examples 'item reference' do
  context 'validations' do
    context 'instance validations' do
      let(:product) { create :product }
      let(:variant) { create :variant }

      context 'both product and variant specified' do
        subject { build factory, product: product, variant: variant }
        it { is_expected.to be_invalid }
      end

      context 'neither product nor variant specified' do
        subject { build factory }
        it { is_expected.to be_invalid }
      end

      context 'only product specified' do
        subject { build(factory, product: product) }
        it { is_expected.to be_valid }
      end

      context 'only variant specified' do
        subject { build(factory, variant: variant) }
        it { is_expected.to be_valid }
      end
    end
  end
end
