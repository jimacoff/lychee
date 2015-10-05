RSpec.shared_examples 'markup' do
  context 'table structure' do
    it { is_expected.to have_db_column(:markup).of_type(:text) }
    it { is_expected.to have_db_column(:markup_format).of_type(:integer) }
  end

  context 'validations' do
    it { is_expected.to validate_presence_of :markup }

    it 'stores an enum describing markup format' do
      expect(subject).to define_enum_for(:markup_format)
        .with([:html, :common_mark])
    end
  end
end
