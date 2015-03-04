require 'rails_helper'

RSpec.describe Site, type: :model do
  has_context 'versioned'

  context 'table structure' do
    it { is_expected.to have_db_column(:name).of_type(:string) }
    it do
      is_expected.to have_db_column(:operating_currency)
        .of_type(:string).with_options(default: 'USD')
    end
  end

  context 'relationships' do
    it { is_expected.to have_many :whitelisted_countries }
    it { is_expected.to have_many :blacklisted_countries }
    it { is_expected.to have_many :prioritized_countries }
  end

  context 'validations' do
    it { is_expected.to validate_presence_of :name }
    it { is_expected.to validate_presence_of :operating_currency }

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
      context 'prioritized countries' do
        let(:country1) { create :country }
        let(:country2) { create :country }
        let(:country3) { create :country }

        context 'only prioritized countries specified' do
          before do
            subject.prioritized_countries << create(:prioritized_country,
                                                    site: subject,
                                                    country: country1)
          end

          it { is_expected.to be_valid }
          it 'has prioritized_countries' do
            expect(subject.prioritized_countries).to be_present
          end
          it 'has no whitelisted_countries' do
            expect(subject.whitelisted_countries).not_to be_present
          end
        end

        context 'with whitelist' do
          RSpec.shared_examples 'expected whitelisted country state' do
            it 'has prioritized_countries' do
              expect(subject.prioritized_countries).to be_present
            end
            it 'has whitelisted_countries' do
              expect(subject.whitelisted_countries).to be_present
            end
          end

          context 'all prioritized countries are whitelisted' do
            before do
              subject.whitelisted_countries << create(:whitelisted_country,
                                                      site: subject,
                                                      country: country1)
              subject.whitelisted_countries << create(:whitelisted_country,
                                                      site: subject,
                                                      country: country2)
              subject.prioritized_countries << create(:prioritized_country,
                                                      site: subject,
                                                      country: country1)
              subject.prioritized_countries << create(:prioritized_country,
                                                      site: subject,
                                                      country: country2)
            end

            it { is_expected.to be_valid }
            has_context 'expected whitelisted country state'
          end
          context 'prioritized countries are whitelisted' do
            before do
              subject.whitelisted_countries << create(:whitelisted_country,
                                                      site: subject,
                                                      country: country1)
              subject.whitelisted_countries << create(:whitelisted_country,
                                                      site: subject,
                                                      country: country2)
              subject.prioritized_countries << create(:prioritized_country,
                                                      site: subject,
                                                      country: country1)
            end

            it { is_expected.to be_valid }
            has_context 'expected whitelisted country state'
          end
          context 'prioritized countries are not whitelisted' do
            before do
              subject.whitelisted_countries << create(:whitelisted_country,
                                                      site: subject,
                                                      country: country1)
              subject.prioritized_countries << create(:prioritized_country,
                                                      site: subject,
                                                      country: country2)
              subject.prioritized_countries << create(:prioritized_country,
                                                      site: subject,
                                                      country: country3)
            end

            it { is_expected.not_to be_valid }
            has_context 'expected whitelisted country state'
          end
        end

        context 'with blacklist' do
          RSpec.shared_examples 'expected blacklisted country state' do
            it 'has prioritized_countries' do
              expect(subject.prioritized_countries).to be_present
            end
            it 'has blacklisted_countries' do
              expect(subject.blacklisted_countries).to be_present
            end
          end

          context 'prioritized countries are not blacklisted' do
            before do
              subject.blacklisted_countries << create(:blacklisted_country,
                                                      site: subject,
                                                      country: country1)
              subject.prioritized_countries << create(:prioritized_country,
                                                      site: subject,
                                                      country: country2)
              subject.prioritized_countries << create(:prioritized_country,
                                                      site: subject,
                                                      country: country3)
            end

            it { is_expected.to be_valid }
            has_context 'expected blacklisted country state'
          end
          context 'prioritized countries are blacklisted' do
            before do
              subject.blacklisted_countries << create(:blacklisted_country,
                                                      site: subject,
                                                      country: country1)
              subject.prioritized_countries << create(:prioritized_country,
                                                      site: subject,
                                                      country: country1)
              subject.prioritized_countries << create(:prioritized_country,
                                                      site: subject,
                                                      country: country2)
            end

            it { is_expected.not_to be_valid }
            has_context 'expected blacklisted country state'
          end
        end
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
    end
  end
end
