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

    it { is_expected.to have_many :products }
    it { is_expected.to have_many :variants }
    it { is_expected.to have_many :categories }
    it { is_expected.to have_many :primary_categories }

    it { is_expected.to have_one :subscriber_address }
  end

  context 'validations' do
    it { is_expected.to validate_presence_of :name }

    context 'instance validations' do
      subject { create(:site) }
      it { is_expected.to be_valid }

      context 'without subscriber address' do
        subject { create(:site, subscriber_address: nil) }
        it 'is invalid' do
          expect(subject.reload).not_to be_valid
        end
      end

      context 'without primary tax category' do
        subject { create(:site, primary_tax_category: nil) }
        it 'is invalid' do
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
          expect { subject.currency = nil }.to raise_error
        end
        it 'unknown ISO code' do
          expect { subject.currency = 'not_a_code' }.to raise_error
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
      it { is_expected.to raise_error }
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
