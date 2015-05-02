RSpec.shared_examples 'hierarchy conversion' do
  context 'hierarchy format' do
    let(:country) { create :country }
    subject do
      create factory, country: country, state: nil,
                      postcode: nil, locality: nil
    end

    it 'top level is country iso code' do
      expect(subject.send(:hierarchy_conversion))
        .to eq(subject.country.iso_alpha2)
    end

    context 'with state' do
      let(:state) { create :state, country: country }
      subject do
        create factory, country: country, state: state,
                        postcode: nil, locality: nil
      end

      it 'appends to hierarchy' do
        expect(subject.send(:hierarchy_conversion))
          .to eq("#{country.iso_alpha2}.#{state.iso_code}")
      end

      context 'with postcode' do
        let(:postcode) { Faker::Lorem.word }
        subject do
          create factory, country: country, state: state,
                          postcode: postcode, locality: nil
        end

        it 'appends to hierarchy' do
          expect(subject.send(:hierarchy_conversion))
            .to eq("#{country.iso_alpha2}.#{state.iso_code}.#{postcode}")
        end

        context 'with locality(city)' do
          let(:locality) { Faker::Lorem.word }
          subject do
            create factory, country: country, state: state,
                            postcode: postcode, locality: locality
          end

          it 'appends to hierarchy' do
            expect(subject.send(:hierarchy_conversion))
              .to eq(
                "#{country.iso_alpha2}.#{state.iso_code}" \
                ".#{postcode}.#{locality}")
          end
        end
      end
    end
  end
end
