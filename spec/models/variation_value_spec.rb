require 'rails_helper'

RSpec.describe VariationValue, type: :model, site_scoped: true do
  has_context 'parent site' do
    let(:factory) { :variation_value }
  end
  has_context 'versioned'

  context 'table structure' do
    it { is_expected.to have_db_column(:name).of_type(:string) }
    it { is_expected.to have_db_column(:description).of_type(:string) }

    it { is_expected.to have_db_column(:order).of_type(:integer) }

    it 'should have non nullable column variation_id of type bigint' do
      expect(subject).to have_db_column(:variation_id)
        .of_type(:integer)
        .with_options(limit: 8, null: false)
    end
    it { is_expected.to have_db_index(:variation_id) }

    it do
      is_expected.not_to have_db_index([:site_id, :variation_id, :order]).unique
    end
  end

  context 'relationships' do
    it { is_expected.to belong_to(:variation).class_name('Variation') }
  end

  context 'validations' do
    it { is_expected.to validate_presence_of :variation }
    it { is_expected.to validate_presence_of :order }
    it { is_expected.to validate_presence_of :name }
    it { is_expected.not_to validate_presence_of :description }

    context 'instance validations' do
      subject { create :variation_value }
    end
  end
end
