require 'rails_helper'

RSpec.describe VariationInstance, type: :model do
  has_context 'metadata'

  context 'table structure' do
    it { is_expected.to have_db_column(:value).of_type(:string) }
  end

  context 'relationships' do
    it { is_expected.to belong_to :variation }
    it { is_expected.to belong_to :variant }
  end

  context 'validations' do
    it { is_expected.to validate_presence_of :variation }
    it { is_expected.to validate_presence_of :variant }
    it { is_expected.to validate_presence_of :value }
  end
end
