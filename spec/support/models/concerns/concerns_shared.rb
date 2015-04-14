RSpec.shared_examples 'taggable' do
  it { is_expected.to be_a_kind_of(Taggable) }

  context 'table structure' do
    it 'has defined tags field as text array' do
      expect(subject).to have_db_column(:tags)
        .of_type(:text).with_options(array: false, default: [])
    end
  end
end

RSpec.shared_examples 'metadata' do
  it { is_expected.to be_a_kind_of(Metadata) }

  context 'table structure' do
    it { is_expected.to have_db_column(:metadata).of_type(:hstore) }
  end
end

RSpec.shared_examples 'specification' do
  it { is_expected.to be_a_kind_of(Specification) }

  context 'table structure' do
    it { is_expected.to have_db_column(:specifications).of_type(:json) }
  end
end

RSpec.shared_examples 'slug' do
  it { is_expected.to be_a_kind_of(Slug) }

  context 'table structure' do
    it { is_expected.to have_db_column(:generated_slug).of_type(:string) }
    it { is_expected.to have_db_column(:specified_slug).of_type(:string) }
  end

  context 'generated slug' do
    it 'is generated from name' do
      expect(subject.generated_slug).to eq(subject.name.to_url)
    end
  end
end
