RSpec.shared_examples 'content' do
  has_context 'metadata'
  has_context 'taggable'
  has_context 'routable'

  context 'relationships' do
    it { is_expected.to have_many(:image_instances) }
    it { is_expected.to have_many(:images) }
  end
end
