RSpec.shared_examples 'routable' do
  has_context 'enablement'

  context 'relationships' do
    it { is_expected.to have_one :path }
  end

  describe '#uri_path' do
    let(:expected_uri_path) do
      "/#{routable.path.self_and_ancestors.reverse.map(&:segment).join('/')}"
    end
    subject { routable.uri_path }

    context 'with path' do
      let(:routable) { create factory, :routable }
      it { is_expected.to eq(expected_uri_path) }
    end

    context 'without path' do
      let(:routable) { create factory }
      it { is_expected.to be_nil }
    end
  end

  describe '#routable?' do
    context 'with path' do
      subject { create factory, :routable }

      context 'enabled' do
        it { is_expected.to be_routable }
      end

      context 'disabled' do
        before { subject.update(enabled: false) }
        it { is_expected.not_to be_routable }
      end
    end

    context 'without path' do
      subject { create factory }

      context 'enabled' do
        it { is_expected.not_to be_routable }
      end

      context 'disabled' do
        before { subject.update(enabled: false) }
        it { is_expected.not_to be_routable }
      end
    end
  end

  describe '#create_default_path' do
    subject { create factory }
    it 'does not throw' do
      expect { subject.create_default_path }
        .not_to raise_error
    end
  end
end
