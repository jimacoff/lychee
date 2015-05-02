RSpec.shared_examples 'geographic hierarchy' do
  context 'table structure' do
    it { is_expected.to have_db_column(:postcode).of_type(:string) }
    it { is_expected.to have_db_column(:locality).of_type(:string) }

    it { is_expected.to have_db_column(:geographic_hierarchy).of_type(:ltree) }
    it { is_expected.to have_db_index(:geographic_hierarchy) }
  end

  context 'relationships' do
  end

  context 'validations' do
    it { is_expected.to validate_presence_of :geographic_hierarchy }

    context 'instance validations' do
      context 'updating hierarchy' do
        subject { build factory }
        it 'updates hierarchy before validation' do
          expect { subject.validate }.to change(subject, :geographic_hierarchy)
        end
      end

      context 'postcode' do
        subject { build factory, postcode: '1234' }
        it 'is invalid without state being specified' do
          expect(subject).not_to be_valid
          expect(subject.errors[:postcode].size).to eq(1)
        end
      end

      context 'locality (city)' do
        subject { build factory, locality: Faker::Lorem.word }
        it 'is invalid without state being specified' do
          subject.postcode = Faker::Number.number(5)
          expect(subject).not_to be_valid
          expect(subject.errors[:locality].size).to eq(1)
        end
        it 'is invalid without postcode being specified' do
          subject.state = create :state, country: subject.country
          expect(subject).not_to be_valid
          expect(subject.errors[:locality].size).to eq(1)
        end
        it 'is invalid without either state or postcode being specified' do
          expect(subject).not_to be_valid
          expect(subject.errors[:locality].size).to eq(1)
        end
      end
    end
  end

  context 'taxation hierarchy' do
    context 'sanitizing hierarchy' do
      subject { create :tax_rate }

      describe '#ltree_sanitize' do
        it 'removes all characters outside [^0-9A-Za-z]' do
          subject.geographic_hierarchy = nil
          expect(
            subject.send(:ltree_sanitize, '.thi!s.is.^an id#ent if.ier.', nil))
            .to eq('thisisanidentifier')
        end
      end

      describe '#determine_geographic_hierarchy' do
        let(:state) { create :state }
        subject do
          create :tax_rate, state: state,
                            country: state.country,
                            postcode: '.1 # 2 3. 4    5',
                            locality: 'c i&ty.'
        end
        it 'sets hierarchy to valid ltree value' do
          subject.send(:determine_geographic_hierarchy)
          expect(subject.geographic_hierarchy)
            .to eq(
              "#{subject.country.iso_alpha2}.#{subject.state.iso_code}" \
              '.12345.city')
        end
      end
    end
  end
end
