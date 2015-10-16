RSpec.shared_examples 'taggable' do
  it { is_expected.to be_a_kind_of(Taggable) }

  context 'table structure' do
    it 'has defined tags field as text array' do
      expect(subject).to have_db_column(:tags)
        .of_type(:text).with_options(array: false, default: [])
    end
  end
end

RSpec.shared_examples 'specification' do
  it { is_expected.to be_a_kind_of(Specification) }

  context 'table structure' do
    it { is_expected.to have_db_column(:specifications).of_type(:json) }
  end
end
