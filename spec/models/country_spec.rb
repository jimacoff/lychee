require 'rails_helper'

RSpec.describe Country, type: :model do
  has_context 'versioned'

  context 'validations' do
    it { is_expected.to validate_presence_of :name }
    it { is_expected.to validate_presence_of :iso_alpha2 }
    it { is_expected.to validate_presence_of :iso_alpha3 }
  end
end
