RSpec.shared_examples 'parent country' do
  subject { build factory }

  context 'table structure' do
    it { is_expected.to have_db_column(:state_id).of_type(:integer) }
    it { is_expected.to have_db_column(:country_id).of_type(:integer) }
  end

  context 'validations' do
    it { is_expected.to validate_presence_of :country }
  end

  describe '#state=' do
    it 'fails when country of state is not the country of the host' do
      subject.country = create :country
      expect { subject.state = create :state }.to raise_error
    end

    it 'succeeds when country of state is the country of the host' do
      subject.country = create :country
      expect { subject.state = create(:state, country: subject.country) }
        .to change(subject, :state)
    end
  end
end
