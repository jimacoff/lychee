require 'rails_helper'

RSpec.describe CategoryMember, type: :model, site_scoped: true do
  has_context 'parent site' do
    let(:factory) { :product_category_member }
  end
  has_context 'commodity reference' do
    let(:factory) { :category_member }
  end

  has_context 'versioned'

  context 'table structure' do
    it { is_expected.to have_db_column(:description).of_type(:string) }
  end

  context 'validations' do
    it { is_expected.to validate_presence_of(:category) }
    it { is_expected.to validate_presence_of(:description) }
  end

  context 'image' do
    it 'stores an image instance to represent the product/variant in a category'
  end
end
