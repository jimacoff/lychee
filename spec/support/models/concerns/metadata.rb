RSpec.shared_examples 'metadata' do
  it { is_expected.to be_a_kind_of(Metadata) }

  context 'table structure' do
    it { is_expected.to have_db_column(:metadata).of_type(:hstore) }
    it { is_expected.to have_db_column(:metadata_fields).of_type(:json) }
  end
end
