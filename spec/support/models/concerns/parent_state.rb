RSpec.shared_examples 'parent state' do
  subject { build factory }

  it { is_expected.to be_a_kind_of(ParentState) }

  context 'table structure' do
    it 'should have column state_id of type bigint' do
      expect(subject).to have_db_column(:state_id)
        .of_type(:integer)
        .with_options(limit: 8, null: true)
    end
    it { is_expected.to have_db_index(:state_id) }
  end

  context 'relationships' do
    it { is_expected.to belong_to(:state).class_name('State') }
  end

  context 'validations' do
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
