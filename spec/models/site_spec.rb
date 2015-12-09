require 'rails_helper'

RSpec.describe Site, type: :model do
  has_context 'versioned'
  has_context 'metadata'

  context 'table structure' do
    it { is_expected.to have_db_column(:name).of_type(:string) }
    it { is_expected.to have_db_column(:currency_iso_code).of_type(:string) }
  end

  context 'relationships' do
    it { is_expected.to have_many :whitelisted_countries }
    it { is_expected.to have_many :blacklisted_countries }
    it { is_expected.to have_many :prioritized_countries }

    it { is_expected.to have_many :tax_categories }
    it { is_expected.to have_one :primary_tax_category }

    it { is_expected.to have_many :images }
    it { is_expected.to have_many :products }
    it { is_expected.to have_many :variants }
    it { is_expected.to have_many :categories }
    it { is_expected.to have_many :primary_categories }
    it { is_expected.to have_many :shipping_rates }

    it { is_expected.to belong_to :subscriber_address }
    it { is_expected.to have_one :preferences }
  end

  context 'validations' do
    it { is_expected.to validate_presence_of :name }

    context 'instance validations' do
      subject { create(:site) }

      it { is_expected.to be_valid }

      context 'when disabled' do
        subject { create(:site, :disabled) }

        it { is_expected.not_to validate_presence_of(:subscriber_address) }
        it { is_expected.not_to validate_presence_of(:primary_tax_category) }

        it 'is valid without preferences' do
          subject.preferences.destroy
          expect(subject.reload).to be_valid
        end
      end

      context 'when disabled' do
        it { is_expected.to validate_presence_of(:subscriber_address) }
        it { is_expected.to validate_presence_of(:primary_tax_category) }

        it 'is invalid without preferences' do
          subject.preferences.destroy
          expect(subject.reload).not_to be_valid
        end
      end

      context 'countries' do
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

          before { Site.current = subject }

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
                                                        country: country1)
                subject.prioritized_countries << create(:prioritized_country,
                                                        country: country1)
                subject.prioritized_countries << create(:prioritized_country,
                                                        country: country2)
              end

              # it { is_expected.not_to be_valid }
              it 'is expected not to be valid' do
                expect(subject).not_to be_valid
              end
              has_context 'expected blacklisted country state'
            end
          end
        end

        describe '#countries' do
          before { create_list(:country, 10) }
          context 'whitelisted countries' do
            before do
              subject.whitelisted_countries <<
                create_list(:whitelisted_country, 3, site: subject)
            end

            it 'only supplies whitelisted countries' do
              expect(subject.countries.size).to eq(3)
              expect(subject.countries)
                .to contain_exactly(
                  *subject.whitelisted_countries.map(&:country))
            end
          end
          context 'blacklisted countries' do
            before do
              subject.blacklisted_countries <<
                create_list(:blacklisted_country, 3, site: subject)
            end

            it 'only supplies non blacklisted countries' do
              expect(subject.countries.size).to eq(Country.count - 3)
              expect(subject.countries)
                .to contain_exactly(
                  *(Country.all - subject.blacklisted_countries.map(&:country)))
            end
          end
          context 'neither white nor blacklisted countries' do
            it 'provides all known countries' do
              expect(subject.countries.size).to eq(Country.count)
              expect(subject.countries).to contain_exactly(*Country.all)
            end
          end
        end
      end
    end
  end

  context 'callbacks' do
    it { is_expected.to callback(:reload_current).after(:save) }
  end

  context 'currency' do
    let(:site) { create(:site) }
    subject { site }

    describe '#currency=' do
      context 'prevents invalid currencies' do
        it 'nil' do
          expect { subject.currency = nil }
            .to raise_error(Money::Currency::UnknownCurrency)
        end
        it 'unknown ISO code' do
          expect { subject.currency = 'not_a_code' }
            .to raise_error(Money::Currency::UnknownCurrency)
        end
      end
      context 'valid currency' do
        def run
          site.currency = 'JPY'
        end

        subject { -> { run } }

        it { is_expected.not_to raise_error }
        it { is_expected.to change(site, :currency_iso_code).to('JPY') }
      end
    end
    describe '#currency' do
      subject { site.currency.iso_code }
      it { is_expected.to eq(site.currency_iso_code) }
    end
    describe '#currency_iso_code=' do
      subject { -> { site.currency_iso_code = 'X' } }
      it { is_expected.to raise_error(/cannot be called.*use Site#currency=/) }
    end
  end

  context 'countries' do
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
