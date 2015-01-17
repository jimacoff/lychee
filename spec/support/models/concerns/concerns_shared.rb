RSpec.shared_examples 'taggable' do
  it { is_expected.to be_a_kind_of(Taggable) }

  it 'has defined tags field as text array' do
    expect(subject).to have_db_column(:tags)
      .of_type(:text).with_options(array: false, default: {})
  end
end

RSpec.shared_examples 'metadata' do
  it { is_expected.to be_a_kind_of(Metadata) }

  it { is_expected.to have_db_column(:metadata).of_type(:hstore) }
end

RSpec.shared_examples 'specification' do
  it { is_expected.to be_a_kind_of(Specification) }

  it { is_expected.to have_db_column(:specifications).of_type(:json) }
end

RSpec.shared_examples 'slug' do
  it { is_expected.to be_a_kind_of(Slug) }
  it { is_expected.to have_db_column(:generated_slug).of_type(:string) }
  it { is_expected.to have_db_column(:specified_slug).of_type(:string) }

  context 'generated slug' do
    it 'is generated from name' do
      expect(subject.generated_slug).to eq(subject.name.to_url)
    end
  end
end
