require 'rails_helper'

RSpec.describe ImageInstance, type: :model, site_scoped: true do
  has_context 'parent site' do
    let(:factory) { :image_instance }
  end
  has_context 'versioned'
  has_context 'metadata'

  context 'table structure' do
    it { is_expected.to have_db_column(:imageable_type).of_type(:string) }

    it 'should have non nullable column imageable_id of type bigint' do
      expect(subject).to have_db_column(:imageable_id)
        .of_type(:integer)
        .with_options(limit: 8, null: false)
    end
    it { is_expected.to have_db_index([:imageable_type, :imageable_id]) }
    it { is_expected.to have_db_index(:imageable_type) }
  end

  context 'relationships' do
    it { is_expected.to belong_to(:image).class_name('Image') }
    it { is_expected.to belong_to(:imageable) }
  end

  context 'validations' do
    it { is_expected.to validate_presence_of :image }
    it { is_expected.to validate_presence_of :imageable }
  end

  context 'polymorphic relationships' do
    context 'category_member' do
      subject { create :image_instance, :for_product_category }
      it { is_expected.to be_valid }
    end

    context 'variation_instance' do
      subject { create :image_instance, :for_variation_instance }
      it { is_expected.to be_valid }
    end

    context 'product' do
      subject { create :image_instance, :for_product }
      it { is_expected.to be_valid }
    end

    context 'category' do
      subject { create :image_instance, :for_category }
      it { is_expected.to be_valid }
    end
  end
end
