require 'rails_helper'

RSpec.describe CategoryMember, type: :model, site_scoped: true do
  has_context 'parent site' do
    let(:factory) { :product_category_member }
  end
  has_context 'versioned'

  context 'table structure' do
    it { is_expected.to have_db_column(:description).of_type(:string) }
    it { is_expected.not_to have_db_column(:variant_id) }
  end

  context 'relationships' do
    it { is_expected.to belong_to(:category) }
    it { is_expected.to belong_to(:product) }
    it { is_expected.to have_one(:image_instance) }
    it { is_expected.to have_one(:image) }
  end

  context 'validations' do
    it { is_expected.to validate_presence_of(:category) }
    it { is_expected.not_to validate_presence_of(:description) }
  end
end
