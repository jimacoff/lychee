require 'rails_helper'

RSpec.describe PrioritizedCountry, type: :model do
  has_context 'versioned'

  context 'relationships' do
    it { is_expected.to belong_to :site }
    it { is_expected.to belong_to :country }
  end
end
