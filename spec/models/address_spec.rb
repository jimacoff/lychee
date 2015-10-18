require 'rails_helper'

RSpec.describe Address, type: :model, site_scoped: true do
  has_context 'parent site' do
    let(:factory) { :address }
  end
  has_context 'parent country' do
    let(:factory) { :address }
  end
  has_context 'parent state' do
    let(:factory) { :address }
  end
  has_context 'geographic hierarchy conversion' do
    let(:factory) { :address }
  end
  has_context 'versioned'
  has_context 'metadata'

  context 'table structure' do
    it { is_expected.to have_db_column(:line1).of_type(:string) }
    it { is_expected.to have_db_column(:line2).of_type(:string) }
    it { is_expected.to have_db_column(:line3).of_type(:string) }
    it { is_expected.to have_db_column(:line4).of_type(:string) }

    it { is_expected.to have_db_column(:locality).of_type(:string) }
    it { is_expected.to have_db_column(:postcode).of_type(:string) }
  end

  context 'validations' do
    it { is_expected.to validate_presence_of :line1 }

    context 'instance validations' do
      context 'states' do
        context 'with country that does not require state' do
          let(:country) { create :country }
          subject do
            create(:address, country: country)
          end
          it 'is valid when address has no linked state' do
            expect(subject).to be_valid
          end
          it 'is invalid when address has linked state' do
            subject.state = create :state, country: country
            expect(subject).not_to be_valid
          end
        end

        context 'with country that specifies states' do
          let(:country) { create :country, :with_states }
          let(:state) { create :state, country: country }
          subject do
            create(:address, state: state, country: country)
          end
          it 'is invalid when address has no linked state' do
            subject.state = nil
            expect(subject).not_to be_valid
          end
          it 'is valid when address has linked state' do
            expect(subject).to be_valid
          end
        end
      end
    end
  end

  describe '#to_s' do
    let(:country) { create(:country) }
    subject { create(:address, country: country) }

    context 'domestic' do
      context 'site country is the same as address country' do
        subject { create(:address, country: Site.current.country) }
        it 'country is not requested in address format' do
          expect(Site.current.country).to receive(:format_postal_address)
            .with(subject, false)
          subject.to_s
        end
      end

      context 'site country differs from address country' do
        it 'country is not requested in address format' do
          expect(country).to receive(:format_postal_address)
            .with(subject, true)
          subject.to_s
        end
      end
    end

    it 'calls the countries address method forcing international format' do
      expect(country).to receive(:format_postal_address)
        .with(subject, true)
      subject.to_s(true)
    end
  end

  describe '#state?' do
    subject { create(:address) }
    it 'is false when state is not specified' do
      expect(subject.state?).not_to be
    end
    it 'is true when state is specified' do
      subject.state = create(:state, country: subject.country)
      expect(subject.state?).to be
    end
  end

  describe '#to_geographic_hierarchy' do
    subject do
      create :address, :with_state,
             postcode: Faker::Lorem.word, locality: Faker::Lorem.word
    end
    it 'sets geographic hierarchy to valid ltree value' do
      expect(subject.to_geographic_hierarchy)
        .to eq(
          "#{subject.country.iso_alpha2}.#{subject.state.iso_code}" \
          ".#{subject.postcode}.#{subject.locality}")
    end
  end
end
