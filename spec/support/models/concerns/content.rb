RSpec.shared_examples 'content' do
  has_context 'metadata'
  has_context 'slug' do
    subject { create factory }
  end
  has_context 'taggable'

  describe '#path' do
    it 'has been overridden' do
      expect { subject.path }.not_to raise_exception
    end
  end
end
