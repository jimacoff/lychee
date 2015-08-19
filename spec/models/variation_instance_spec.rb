require 'rails_helper'

RSpec.describe VariationInstance, type: :model, site_scoped: true do
  has_context 'parent site' do
    let(:factory) { :variation_instance }
  end

  has_context 'versioned'
  has_context 'metadata'

  let(:uniq_value_cols) { [:variant_id, :variation_id, :value] }

  context 'table structure' do
    it { is_expected.to have_db_column(:value).of_type(:string) }

    it { is_expected.to have_db_column(:name).of_type(:string) }
    it { is_expected.to have_db_column(:description).of_type(:string) }

    it { is_expected.to have_db_column(:render_as).of_type(:integer) }

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
    it { is_expected.to have_db_index(uniq_value_cols).unique(true) }
  end

  context 'relationships' do
    it { is_expected.to belong_to(:variation).class_name('Variation') }
    it { is_expected.to belong_to(:variant).class_name('Variant') }
  end

  context 'validations' do
    it { is_expected.to validate_presence_of :variation }
    it { is_expected.to validate_presence_of :variant }
    it { is_expected.to validate_presence_of :value }

    it { is_expected.to validate_presence_of :name }
    it { is_expected.to validate_presence_of :description }
    it { is_expected.to validate_presence_of :render_as }
  end

  context 'frontend rendering' do
    it 'stores an enum to dictate html type' do
      expect(subject).to define_enum_for(:render_as)
        .with([:radio, :drop_down])
    end
  end

  context 'allows users to choose this instance via image' do
    it 'links to an image'
  end
end
