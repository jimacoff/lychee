RSpec.shared_examples 'versioned' do
  it { is_expected.to respond_to(:versions) }
end
