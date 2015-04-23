RSpec.shared_examples 'hierarchy' do
  context 'table structure' do
    it { is_expected.to have_db_column(:postcode).of_type(:string) }
    it { is_expected.to have_db_column(:city).of_type(:string) }
  end

  context 'relationships' do
  end

  context 'validations' do
    it { is_expected.to validate_presence_of :hierarchy }

    context 'instance validations' do
      context 'updating hierarchy' do
        subject { build factory }
        it 'updates hierarchy before validation' do
          expect { subject.validate }.to change(subject, :hierarchy)
        end
      end

      context 'postcode' do
        subject { build factory, postcode: '1234' }
        it 'is invalid without state being specified' do
          expect(subject).not_to be_valid
          expect(subject.errors[:postcode].size).to eq(1)
        end
      end

      context 'city' do
        subject { build factory, city: Faker::Lorem.word }
        it 'is invalid without state being specified' do
          subject.postcode = Faker::Number.number(5)
          expect(subject).not_to be_valid
          expect(subject.errors[:city].size).to eq(1)
        end
        it 'is invalid without postcode being specified' do
          subject.state = create :state, country: subject.country
          expect(subject).not_to be_valid
          expect(subject.errors[:city].size).to eq(1)
        end
        it 'is invalid without either state or postcode being specified' do
          expect(subject).not_to be_valid
          expect(subject.errors[:city].size).to eq(1)
        end
      end
    end
  end

  context 'taxation hierarchy' do
    context 'sanitizing hierarchy' do
      subject { create :tax_rate }

      describe '#ltree_sanitize' do
        it 'removes all characters outside [^0-9A-Za-z]' do
          subject.hierarchy = nil
          expect(subject.send(:ltree_sanitize, '.thi!s.is.^an id#ent if.ier.'))
            .to eq('thisisanidentifier')
        end
      end

      describe '#determine_hierarchy' do
        let(:state) { create :state }
        subject do
          create :tax_rate, state: state,
                            country: state.country,
                            postcode: '.1 # 2 3. 4    5',
                            city: 'c i&ty.'
        end
        it 'sets hierarchy to valid ltree value' do
          subject.send(:determine_hierarchy)
          expect(subject.hierarchy)
            .to eq(
              "#{subject.country.iso_alpha2}.#{subject.state.iso_code}" \
              '.12345.city')
        end
      end
    end

    context 'hierarchy format' do
      let(:country) { create :country }
      subject { create factory, country: country }

      it 'top level is country iso code' do
        expect(subject.hierarchy).to eq(subject.country.iso_alpha2)
      end

      context 'with state' do
        let(:state) { create :state, country: country }
        subject { create factory, state: state, country: country }
        it 'appends to hierarchy' do
          expect(subject.hierarchy)
            .to eq("#{country.iso_alpha2}.#{state.iso_code}")
        end

        context 'with postcode' do
          let(:postcode) { Faker::Lorem.word }
          subject do
            create factory, country: country,
                            state: state, postcode: postcode
          end

          it 'appends to hierarchy' do
            expect(subject.hierarchy)
              .to eq("#{country.iso_alpha2}.#{state.iso_code}.#{postcode}")
          end

          context 'with city' do
            let(:city) { Faker::Lorem.word }
            subject do
              create factory, country: country, state: state,
                              postcode: postcode, city: city
            end

            it 'appends to hierarchy' do
              expect(subject.hierarchy)
                .to eq(
                  "#{country.iso_alpha2}.#{state.iso_code}" \
                  ".#{postcode}.#{city}")
            end
          end
        end
      end
    end
  end
end
