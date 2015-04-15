require 'rails_helper'

RSpec.describe CategoryMember, type: :model, site_scoped: true do
  has_context 'parent site' do
    let(:factory) { :product_category_member }
  end
  has_context 'commodity reference' do
    let(:factory) { :category_member }
  end

  has_context 'versioned'

  context 'validations' do
    it { is_expected.to validate_presence_of(:category) }
  end
end
