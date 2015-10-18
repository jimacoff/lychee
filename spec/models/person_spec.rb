require 'rails_helper'

RSpec.describe Person, type: :model, site_scoped: true do
  has_context 'parent site' do
    let(:factory) { :person }
  end

  context 'table structure' do
    it { is_expected.to have_db_column(:display_name).of_type(:string) }
    it { is_expected.to have_db_column(:email).of_type(:string) }
    it { is_expected.to have_db_column(:phone_number).of_type(:string) }
  end

  context 'relationships' do
    it { is_expected.to have_one(:address) }
  end

  context 'validations' do
    it { is_expected.to validate_presence_of(:display_name) }
    it { is_expected.not_to validate_presence_of(:email) }
    it { is_expected.not_to validate_presence_of(:phone_number) }
  end
end
