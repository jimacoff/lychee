require 'rails_helper'

RSpec.describe Country, type: :model do
  has_context 'versioned'

  context 'table structure' do
    it { is_expected.to have_db_column(:name).of_type(:string) }
    it { is_expected.to have_db_column(:iso_alpha2).of_type(:string) }
    it { is_expected.to have_db_column(:iso_alpha3).of_type(:string) }
    it do
      is_expected.to have_db_column(:postal_address_template).of_type(:string)
    end
  end

  context 'validations' do
    it { is_expected.to validate_presence_of :name }
    it { is_expected.to validate_presence_of :iso_alpha2 }
    it { is_expected.to validate_presence_of :iso_alpha3 }
    it { is_expected.to validate_presence_of :postal_address_template }
  end

  describe '#format_postal_address' do
    let(:site) { FactoryGirl.create(:site) }
    let(:address) { FactoryGirl.create(:address, country: subject, site: site) }
    subject { FactoryGirl.create(:country) }

    context 'all address fields are populated' do
      let(:expected_address) do
        %(#{address.line1}
#{address.line2}
#{address.line3}
#{address.line4}
#{address.locality} #{address.state}  #{address.postcode}).upcase
      end
      it 'provides valid address' do
        address.line3 = Faker::Address.secondary_address
        address.line4 = Faker::Address.secondary_address
        expect(subject.format_postal_address(address)).to eq(expected_address)
      end
    end

    context 'only some address fields are populated' do
      let(:expected_address) do
        %(#{address.line1}
#{address.line2}
#{address.locality}   #{address.postcode}).upcase
      end
      it 'provides valid address' do
        address.state = nil
        expect(subject.format_postal_address(address)).to eq(expected_address)
      end
    end

    context 'country specific postal template' do
      let(:postal_address_template) do
        %(%{line1}
%{locality}
%{line2}
%{postcode} %{state})
      end
      subject do
        FactoryGirl.create(:country,
                           postal_address_template: postal_address_template)
      end
      let(:expected_address) do
        %(#{address.line1}
#{address.locality}
#{address.line2}
#{address.postcode} #{address.state}).upcase
      end
      it 'provides valid address' do
        expect(subject.format_postal_address(address)).to eq(expected_address)
      end
    end
  end
end
