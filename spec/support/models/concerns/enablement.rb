RSpec.shared_examples 'enablement' do
  it { is_expected.to be_a_kind_of(Enablement) }

  context 'table structure' do
    it { is_expected.to have_db_column(:enabled).of_type(:boolean) }
  end

  context 'scopes' do
    context 'default_scope - enabled' do
      let!(:enabled) { create factory, enabled: true }
      let!(:disabled) { create factory, enabled: false }

      it 'has 2 instances' do
        expect(described_class.count).to eq(2)
      end

      it 'only returns enabled instances' do
        expect(described_class.enabled.all).to contain_exactly(enabled)
      end

      it 'returns all instances when unscoped' do
        expect(described_class.all)
          .to contain_exactly(enabled, disabled)
      end
    end
  end
end
