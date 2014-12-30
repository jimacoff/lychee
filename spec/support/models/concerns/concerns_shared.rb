RSpec.shared_examples 'taggable' do
  it { is_expected.to be_a_kind_of(Taggable) }

  it 'has defined tags field as text array' do
    expect(subject).to have_db_column(:tags)
      .of_type(:text)
      .with_options(array: false,
                    default: [])
  end
end

RSpec.shared_examples 'metadata' do
  it { is_expected.to be_a_kind_of(Metadata) }

  it 'has defined metadata field as hstore' do
    expect(subject).to have_db_column(:metadata)
      .of_type(:hstore)
  end
end
