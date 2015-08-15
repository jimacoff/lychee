require 'rails_helper'

RSpec.describe VariationInstance, type: :model, site_scoped: true do
  has_context 'parent site' do
    let(:factory) { :variation_instance }
  end

  has_context 'versioned'
  has_context 'metadata'

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

  context 'value must be unique within a single variation' do
    let(:product) { create :product }
    let(:variation) { create :variation, product: product }
    let!(:variation_instance1) do
      create :variation_instance, variation: variation
    end
    let!(:variation_instance2) do
      create :variation_instance, variation: variation
    end

    context 'within a single product' do
      before do
        variation_instance2.variant = variation_instance1.variant
        variation_instance2.variation = variation_instance1.variation
      end

      it 'is valid when value is unique' do
        expect(variation_instance1).to be_valid
        expect(variation_instance2).to be_valid
      end

      it 'is invalid when value is not unique' do
        variation_instance1.value = variation_instance2.value
        variation_instance1.save
        variation_instance2.save

        expect(variation_instance1).to be_valid
        expect(variation_instance2).not_to be_valid
      end
    end

    context 'across variations' do
      let(:product2) { create :product }
      let(:variation2) { create :variation, product: product2 }
      let(:variation_instance3) do
        create :variation_instance, variation: variation2
      end

      it 'is valid when order is not unique across products' do
        variation_instance3.value = variation_instance3.value
        expect(variation_instance1).to be_valid
        expect(variation_instance2).to be_valid
        expect(variation_instance3).to be_valid
      end
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
end
