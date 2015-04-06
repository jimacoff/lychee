require 'rails_helper'

RSpec.describe Address, type: :model, site_scoped: true do
  has_context 'parent site' do
    let(:factory) { :address }
    let(:site_factory_instances) { 1 }
  end
  has_context 'versioned'
  has_context 'metadata'

  context 'table structure' do
    it { is_expected.to have_db_column(:line1).of_type(:string) }
    it { is_expected.to have_db_column(:line2).of_type(:string) }
    it { is_expected.to have_db_column(:line3).of_type(:string) }
    it { is_expected.to have_db_column(:line4).of_type(:string) }

    it { is_expected.to have_db_column(:locality).of_type(:string) }
    it { is_expected.to have_db_column(:state).of_type(:string) }
    it { is_expected.to have_db_column(:postcode).of_type(:string) }
  end

  context 'relationships' do
    it { is_expected.to belong_to(:order_customer_address) }
    it { is_expected.to belong_to(:order_delivery_address) }
    it { is_expected.to belong_to(:country) }
  end

  context 'validations' do
    it { is_expected.to validate_presence_of :line1 }
    it { is_expected.to validate_presence_of :country }

    context 'instance validations' do
      context 'without order or site address reference' do
        subject { create(:address) }
        it { is_expected.not_to be_valid }
      end
      context 'with multiple address references' do
        subject do
          create(:address, order_customer_address: (create :order),
                           site_subscriber_address: Site.current)
        end
        it { is_expected.not_to be_valid }
      end
      context 'orders' do
        context 'customer association' do
          subject { create(:address, order_customer_address: (create :order)) }
          it { is_expected.to be_valid }
        end
        context 'delivery association' do
          subject { create(:address, order_delivery_address: (create :order)) }
          it { is_expected.to be_valid }
        end
      end
      context 'site' do
        context 'customer association' do
          subject { create(:address, site_subscriber_address: Site.current) }
          it { is_expected.to be_valid }
        end
        context 'delivery association' do
          subject { create(:address, site_distribution_address: Site.current) }
          it { is_expected.to be_valid }
        end
      end
    end
  end

  describe '#to_s' do
    let(:country) { FactoryGirl.create(:country) }
    subject { FactoryGirl.create(:address, country: country) }

    it 'calls the countries format address method' do
      expect(country).to receive(:format_postal_address)
        .with(subject, subject.site.subscriber_address)
      subject.to_s
    end
  end
end
