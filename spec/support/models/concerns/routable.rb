RSpec.shared_examples 'routable' do
  context 'relationships' do
    it { is_expected.to have_one :path }
  end

  describe '#uri_path' do
    let(:parent) { create :path }
    let(:expected_uri_path) { "/#{parent.segment}/#{routable.path.segment}" }
    subject { routable.uri_path }

    context 'with path' do
      let(:routable) { create factory, :routable }
      before { parent.add_child(routable.path) }

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
end
