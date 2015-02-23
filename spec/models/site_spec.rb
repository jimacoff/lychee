require 'rails_helper'

RSpec.describe Site, type: :model do
  has_context 'versioned'

  context 'validations' do
    it { is_expected.to validate_presence_of :name }

    context 'instance validations' do
      subject { create(:site) }
      it { is_expected.to be_valid }
      it 'is valid with whitelisted countries specified' do
        subject.whitelisted_countries << create(:whitelisted_country,
                                                site: subject)
        expect(subject).to be_valid
      end
      it 'is valid with blacklisted countries specified' do
        subject.blacklisted_countries << create(:blacklisted_country,
                                                site: subject)
        expect(subject).to be_valid
      end
      it 'is invalid with whitelisted and blacklisted countries specified' do
        subject.whitelisted_countries << create(:whitelisted_country,
                                                site: subject)
        subject.blacklisted_countries << create(:blacklisted_country,
                                                site: subject)
        expect(subject).not_to be_valid
      end
    end
  end

  context 'country handling' do
    let(:country) { Faker::Lorem.word }
    subject { create(:site) }

    describe '#restricts_countries?' do
      it 'is not restricted if no white or blacklist sites exist' do
        expect(subject.restricts_countries?).not_to be
      end

      it 'is restricted if whitelisted sites exist' do
        subject.whitelisted_countries << create(:whitelisted_country,
                                                site: subject)
        expect(subject.restricts_countries?).to be
      end

      it 'is restricted if blacklisted sites exist' do
        subject.blacklisted_countries << create(:blacklisted_country,
                                                site: subject)
        expect(subject.restricts_countries?).to be
      end

      it 'is restricted if blacklisted and whitelisted sites exist' do
        subject.whitelisted_countries << create(:whitelisted_country,
                                                site: subject)
        subject.blacklisted_countries << create(:blacklisted_country,
                                                site: subject)
        expect(subject.restricts_countries?).to be
      end
    end
  end
end
