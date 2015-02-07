require 'rails_helper'

RSpec.describe Tenant, type: :model do
  it { is_expected.to belong_to :site }

  context 'validations' do
    it { is_expected.to validate_presence_of :site }
    it { is_expected.to validate_presence_of :identifier }
  end
end
