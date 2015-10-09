require 'rails_helper'

RSpec.describe Person, type: :model do
  context 'relationships' do
    it { is_expected.to have_one(:address) }
  end

  context 'validations' do
    it { is_expected.to validate_presence_of(:display_name) }
    it { is_expected.not_to validate_presence_of(:email) }
    it { is_expected.not_to validate_presence_of(:phone_number) }
  end
end
