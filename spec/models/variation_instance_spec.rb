require 'rails_helper'

RSpec.describe VariationInstance, type: :model, site_scoped: true do
  has_context 'parent site' do
    let(:factory) { :variation_instance }
  end

  has_context 'versioned'
  has_context 'metadata'

  context 'table structure' do
    it { is_expected.not_to have_db_column(:value).of_type(:string) }
    it 'should have non nullable column variation_id of type bigint' do
      expect(subject).to have_db_column(:variation_id)
        .of_type(:integer)
        .with_options(limit: 8, null: false)
    end
    it { is_expected.to have_db_index(:variation_id) }

    it 'should have non nullable column variant_id of type bigint' do
      expect(subject).to have_db_column(:variant_id)
        .of_type(:integer)
        .with_options(limit: 8, null: false)
    end
    it { is_expected.to have_db_index(:variant_id) }
  end

  context 'relationships' do
    it { is_expected.to belong_to(:variation).class_name('Variation') }
    it { is_expected.to belong_to(:variant).class_name('Variant') }
    it { is_expected.to have_one(:image_instance) }
    it { is_expected.to have_one(:image) }
  end

  context 'validations' do
    it { is_expected.to validate_presence_of :variation }
    it { is_expected.to validate_presence_of :variant }
  end

  context 'allows users to choose this instance via image' do
    it 'links to an image'
  end
end
