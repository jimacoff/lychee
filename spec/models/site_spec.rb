require 'rails_helper'

RSpec.describe Site, type: :model do
  context 'validations' do
    it { is_expected.to validate_presence_of :name }
  end
end
