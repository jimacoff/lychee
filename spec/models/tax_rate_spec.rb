require 'rails_helper'

RSpec.describe TaxRate, type: :model, site_scoped: true do
  has_context 'parent site' do
    let(:factory) { :tax_rate }
  end
  has_context 'metadata'
  has_context 'versioned'

  context 'table structure' do
    it { is_expected.to have_db_column(:tax_category_id).of_type(:integer) }

    it { is_expected.to have_db_column(:rate).of_type(:decimal) }

    it { is_expected.to have_db_column(:name).of_type(:string) }
    it { is_expected.to have_db_column(:description).of_type(:string) }
    it { is_expected.to have_db_column(:invoice_note).of_type(:string) }

    it { is_expected.to have_db_column(:state).of_type(:string) }
    it { is_expected.to have_db_column(:postcode).of_type(:string) }
    it { is_expected.to have_db_column(:city).of_type(:string) }

    it { is_expected.to have_db_column(:shipping).of_type(:boolean) }

    it { is_expected.to have_db_column(:priority).of_type(:integer) }
    it { is_expected.to have_db_column(:hierarchy).of_type(:ltree) }
  end

  context 'relationships' do
    it { is_expected.to belong_to :country }
  end

  context 'validations' do
    it { is_expected.to validate_presence_of :tax_category }

    it { is_expected.to validate_presence_of :rate }

    it { is_expected.to validate_presence_of :name }
    it { is_expected.to validate_presence_of :description }

    it { is_expected.to validate_presence_of :country }
    it { is_expected.to validate_presence_of :priority }
    it { is_expected.to validate_presence_of :hierarchy }

    context 'instance validations' do
      context 'updating hierarchy' do
        subject { build :tax_rate }
        it 'updates hierarchy before validation' do
          expect { subject.validate }.to change(subject, :hierarchy)
        end
      end

      context 'postcode' do
        subject { build :tax_rate, postcode: '1234' }
        it 'is invalid without state being specified' do
          expect(subject).not_to be_valid
          expect(subject.errors[:postcode].size).to eq(1)
        end
      end

      context 'city' do
        subject { build :tax_rate, city: Faker::Lorem.word }
        it 'is invalid without state being specified' do
          subject.postcode = Faker::Number.number(5)
          expect(subject).not_to be_valid
          expect(subject.errors[:city].size).to eq(1)
        end
        it 'is invalid without postcode being specified' do
          subject.state = Faker::Lorem.word
          expect(subject).not_to be_valid
          expect(subject.errors[:city].size).to eq(1)
        end
        it 'is invalid without either state or postcode being specified' do
          expect(subject).not_to be_valid
          expect(subject.errors[:city].size).to eq(1)
        end
      end

      context 'rate' do
        subject { create :tax_rate }
        it 'must be greater that or equal to 0' do
          expect(subject).to validate_numericality_of(:rate)
            .is_greater_than_or_equal_to(0.0)
        end
        it 'must be less than or equal to 0' do
          expect(subject).to validate_numericality_of(:rate)
            .is_less_than_or_equal_to(1.0)
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
        subject do
          create :tax_rate, state: 's!t a.te',
                            postcode: '.1 # 2 3. 4    5',
                            city: 'c i&ty.'
        end
        it 'sets hierarchy to valid ltree value' do
          subject.send(:determine_hierarchy)
          expect(subject.hierarchy)
            .to eq("#{subject.country.iso_alpha2}.state.12345.city")
        end
      end
    end

    context 'hierarchy format' do
      let(:country) { subject.country }
      subject { create :tax_rate }

      it 'top level is country iso code' do
        expect(subject.hierarchy).to eq(subject.country.iso_alpha2)
      end

      context 'with state' do
        let(:state) { Faker::Lorem.word }
        subject { create :tax_rate, state: state }
        it 'appends to hierarchy' do
          expect(subject.hierarchy).to eq("#{country.iso_alpha2}.#{state}")
        end

        context 'with postcode' do
          let(:postcode) { Faker::Lorem.word }
          subject { create :tax_rate, state: state, postcode: postcode }

          it 'appends to hierarchy' do
            expect(subject.hierarchy)
              .to eq("#{country.iso_alpha2}.#{state}.#{postcode}")
          end

          context 'with city' do
            let(:city) { Faker::Lorem.word }
            subject do
              create :tax_rate, state: state, postcode: postcode, city: city
            end

            it 'appends to hierarchy' do
              expect(subject.hierarchy)
                .to eq("#{country.iso_alpha2}.#{state}.#{postcode}.#{city}")
            end
          end
        end
      end
    end
  end
end
