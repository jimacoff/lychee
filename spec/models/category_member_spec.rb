require 'rails_helper'

RSpec.describe CategoryMember, type: :model, site_scoped: true do
  has_context 'parent site' do
    let(:factory) { :product_category_member }
  end

  # TODO: This should just be Product directly now
  has_context 'commodity reference' do
    let(:factory) { :category_member }
  end

  has_context 'versioned'

  context 'table structure' do
    it { is_expected.to have_db_column(:description).of_type(:string) }
  end

  context 'relationships' do
    it { is_expected.to belong_to(:category) }
    it { is_expected.to have_one(:image_instance) }
    it { is_expected.to have_one(:image) }
  end

  context 'validations' do
    it { is_expected.to validate_presence_of(:category) }

    # TODO: this should actually be optional
    it { is_expected.to validate_presence_of(:description) }
  end
end
