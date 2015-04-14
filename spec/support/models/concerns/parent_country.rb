RSpec.shared_examples 'parent country' do
  subject { build factory }

  it { is_expected.to be_a_kind_of(ParentCountry) }

  context 'table structure' do
    it 'should have non nullable column country_id of type bigint' do
      expect(subject).to have_db_column(:country_id)
        .of_type(:integer)
        .with_options(limit: 8, null: false)
    end
    it { is_expected.to have_db_index(:country_id) }
  end

  context 'relationships' do
    it { is_expected.to belong_to(:country).class_name('Country') }
  end

  context 'validations' do
    it { is_expected.to validate_presence_of :country }
  end
end
